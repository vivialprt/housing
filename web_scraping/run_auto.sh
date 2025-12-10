#!/bin/sh
LOG_LEVEL=$([ "${ENV:-dev}" = "dev" ] && echo "DEBUG" || echo "INFO")
scrapy crawl aruodas -a since=auto -L $LOG_LEVEL