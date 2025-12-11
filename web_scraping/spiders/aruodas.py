import boto3
import os
import json
from enum import StrEnum
from datetime import datetime, timedelta
import scrapy


class PropertyPrefix(StrEnum):
    FLAT_SALE = "1"
    HOUSE_SALE = "2"
    PREMISE_SALE = "3"
    FLAT_RENT = "4"
    HOUSE_RENT = "5"


class AruodasSpider(scrapy.Spider):
    name = "aruodas"
    allowed_domains = ["en.aruodas.lt"]
    start_urls = ["https://en.aruodas.lt/butai/vilniuje/?FOrder=AddDate"]
    custom_settings = {
        "FEEDS": {
            f"S3://{os.environ["OUTPUT_BUCKET"]}/{os.environ["OUTPUT_PREFIX"]}/{datetime.now().strftime("%d%m%Y")}.jsonl": {
                "format": "jsonlines"
            },
            f"{datetime.now().strftime("%d%m%Y")}.jsonl": {
                "format": "jsonlines"
            },
        }
    }

    def __init__(self, since=None, debug=False, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.debug = True if debug == "True" else False

        # Determine since date
        match since:
            case "auto":
                self.since = self._get_last_date_from_s3()
            case str():
                self.since = datetime.strptime(since, "%d%m%Y")
            case None:
                self.since = None

        self.reached_old = False

    def parse(self, r):
        standalone_links = r.css(
            ".list-row-v2.object-row.selflat.advert  div.list-adress-v2 a::attr(href)"
        ).getall()
        project_links = r.css(".variants a::attr(href)").getall()
        next_page_bt = r.css("a.page-bt")[-1]
        next_page = r.follow(next_page_bt.css("::attr(href)").get())
        next_page_text = next_page_bt.css("::text").get()

        for link in standalone_links:
            yield scrapy.Request(link, callback=self.parse_ad)

        for link in project_links:
            yield r.follow(link, callback=self.parse_project)

        if next_page_text == "»" and not self.reached_old:
            yield next_page

    def parse_project(self, r):
        js_pattern = r"loadAdvertProjectAdverts\s*\((.*?)\);"
        obj_type_id, advert_id, _, _, project_id, _, project_owner = (
            r.css("script::text").re_first(js_pattern).split(", ")
        )
        params = {
            "obj": obj_type_id,
            "id": advert_id,
            "project_id": project_id,
            "project_owner": project_owner,
        }
        params_str = "&".join(f"{k}={v}" for k, v in params.items())
        yield r.follow(
            f"/ajax/getProjectAdverts/?{params_str}",
            callback=self.parse_project_variants,
        )

    def parse_project_variants(self, r):
        for link in r.css("td.goto a::attr(href)").getall():
            if link.startswith(f"/{PropertyPrefix.FLAT_SALE}"):
                yield r.follow(link, callback=self.parse_ad)

    def parse_ad(self, r):
        city, district, street, obj_type = (
            r.css(".obj-header-text::text").get().strip().split(", ")
        )

        sold = r.css(".adv-sold1-en").get() is not None
        reserved = r.css(".reservation-strip").get() is not None

        project_name_raw = r.css(".project-in__title::text").get()
        project_name = project_name_raw.strip()[1:-1] if project_name_raw else None
        project_link = (
            r.follow(r.css("a.project-in__button::attr(href)").get()).url
            if project_name_raw
            else None
        )
        project_developer_link = (
            r.css(".projects-popup__developer__url a::attr(href)").get()
            if project_name_raw
            else None
        )

        price_raw = r.css("span.price-eur::text").get().strip()
        price_per_m2_raw = r.css("span.price-per::text").get().strip()

        precise_address_link = r.css(
            "a.link-obj-thumb.vector-thumb-map::attr(href)"
        ).get()

        details_raw = {}
        details_dt = r.css("dl.obj-details dt")
        details_dd = r.css("dl.obj-details dd")
        for dt, dd in zip(details_dt, details_dd):
            key = dt.css("::text").get().strip().replace(":", "")
            if key == "Reklama/pasiūlymas":
                continue
            value = [v for value in dd.css("::text").getall() if (v := value.strip())]
            details_raw[key] = value if len(value) > 1 else value[0]

        decription = "".join(r.css(".obj-comment div::text").getall())

        stats_raw = {}
        if project_name:
            for row in r.css(".project__advert-info__row"):
                key = row.css(".project__advert-info__label ::text").get()
                if key == "Saved":
                    value = row.css(".project__advert-info__value ::text").getall()[1]
                else:
                    value = row.css(".project__advert-info__value ::text").get()
                stats_raw[key.strip()] = value.strip()

        else:
            stats_dt = r.css(".obj-stats dt")
            stats_dd = r.css(".obj-stats dd")
            for dt, dd in zip(stats_dt, stats_dd):
                key = dt.css("::text").get()
                value = "".join(dd.css("::text").get())
                stats_raw[key] = value

        self._check_if_reached_old(stats_raw)

        yield {
            "city": city,
            "district": district,
            "street": street,
            "obj_type": obj_type,
            "sold": sold,
            "reserved": reserved,
            "project_name": project_name,
            "project_link": project_link,
            "project_developer_link": project_developer_link,
            "price_raw": price_raw,
            "price_per_m2_raw": price_per_m2_raw,
            "precise_address_link": precise_address_link,
            "details_raw": details_raw,
            "decription": decription,
            "stats_raw": stats_raw,
            "url": r.url,
        }

    def close(self, reason):
        if reason == "finished":
            self._set_last_date_to_s3()

    def _check_if_reached_old(self, stats_raw):
        if self.since is None:
            return

        created_str = stats_raw.get("Created")
        if created_str is None:
            return

        created_date = datetime.strptime(created_str, "%Y-%m-%d")
        if created_date < self.since:
            self.reached_old = True

    def _get_last_date_from_s3(self):
        if self.debug:
            return datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
        s3 = boto3.client("s3")
        try:
            meta_file = s3.get_object(
                Bucket=os.environ["OUTPUT_BUCKET"],
                Key=f"{os.environ["OUTPUT_PREFIX"]}/crawl_meta.json"
            )
        except s3.exceptions.NoSuchKey:
            raise RuntimeError(f"No crawl metadata found in specified S3 location")
        meta = json.loads(meta_file["Body"].read().decode("utf-8"))
        last_crawl_date_str = meta["latest_crawl_date"]
        return datetime.strptime(last_crawl_date_str, "%d%m%Y")

    def _set_last_date_to_s3(self):
        if self.debug:
            return
        s3 = boto3.client("s3")
        meta = {
            "latest_crawl_date": datetime.now().strftime("%d%m%Y")
        }
        s3.put_object(
            Bucket=os.environ["OUTPUT_BUCKET"],
            Key=f"{os.environ["OUTPUT_PREFIX"]}/crawl_meta.json",
            Body=json.dumps(meta).encode("utf-8")
        )
