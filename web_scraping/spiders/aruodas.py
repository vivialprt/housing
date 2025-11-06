from enum import StrEnum
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
    start_urls = ["https://en.aruodas.lt/butai/vilniuje/"]

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

        if next_page_text == "»":
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

        details_dt = r.css("dl.obj-details dt::text").getall()
        details_dd = [
            selector.css("::text").getall() for selector in r.css("dl.obj-details dd")
        ]

        details_raw = {
            key.replace(":", "").strip(): value
            for key, value in zip(details_dt, details_dd)
        }

        decription = "".join(r.css(".obj-comment div::text").getall())

        stats_dt = r.css(".obj-stats dt::text").getall()
        stats_dd = r.css(".obj-stats dd::text").getall()

        stats_raw = {k: v for k, v in zip(stats_dt, stats_dd)}

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
