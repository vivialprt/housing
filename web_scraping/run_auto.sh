#!/bin/sh
LOG_LEVEL=$([ "${ENV:-dev}" = "dev" ] && echo "DEBUG" || echo "INFO")
scrapy crawl aruodas -a since=08122025 -L $LOG_LEVEL