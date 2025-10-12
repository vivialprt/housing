import scrapy


class AruodasSpider(scrapy.Spider):
    name = "aruodas"
    allowed_domains = ['en.aruodas.lt']
    start_urls = ['https://en.aruodas.lt/butai/vilniuje/']

    def parse(self, r):
        
        standalone_links = r.css('.list-row-v2.object-row.selflat.advert  div.list-adress-v2 a::attr(href)').getall()
        # project_links = r.css('.list-row-v2.object-row.selflat.project-chosen  div.list-adress-v2 a::attr(href)').getall()
        next_page_bt = r.css('a.page-bt')[-1]
        next_page = r.follow(next_page_bt.css('::attr(href)').get())
        next_page_text = next_page_bt.css('::text').get()

        for link in standalone_links:
            yield scrapy.Request(link, callback=self.parse_ad)

        if next_page_text == '»':
            yield next_page

    def parse_ad(self, r):
        city, district, street, obj_type = r.css('.obj-header-text::text').get().strip().split(', ')

        price_raw = r.css('span.price-eur::text').get().strip()
        price_per_m2_raw = r.css('span.price-per::text').get().strip()

        precise_address_link = r.css('a.link-obj-thumb.vector-thumb-map::attr(href)').get()

        details_dt = r.css('dl.obj-details dt::text').getall()
        details_dd = [selector.css('::text').getall() for selector in r.css('dl.obj-details dd')]

        details_raw = {
            key.replace(':', '').strip(): value
            for key, value in zip(details_dt, details_dd)
        }

        decription = ''.join(r.css('.obj-comment div::text').getall())

        stats_dt = r.css('.obj-stats dt::text').getall()
        stats_dd = r.css('.obj-stats dd::text').getall()

        stats_raw = {k: v for k, v in zip(stats_dt, stats_dd)}

        yield {
            'city': city,
            'district': district,
            'street': street,
            'obj_type': obj_type,
            'price_raw': price_raw,
            'price_per_m2_raw': price_per_m2_raw,
            'precise_address_link': precise_address_link,
            'details_raw': details_raw,
            'decription': decription,
            'stats_raw': stats_raw,
            'url': r.url,
        }
