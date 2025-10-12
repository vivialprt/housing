import scrapy


class AruodasSpider(scrapy.Spider):
    name = "aruodas"
    allowed_domains = ["en.aruodas.lt"]
    start_urls = ["https://en.aruodas.lt"]

    def parse(self, response):
        pass
