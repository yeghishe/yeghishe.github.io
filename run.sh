#!/bin/sh
docker run --rm -ti -v $(pwd):/src -p 9003:9003 yeghishe/blog:latest
