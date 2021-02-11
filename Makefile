# sourced from https://opensource.com/article/20/3/blog-emacs

# Makefile for myblog

.PHONY: all publish publish_no_init republish

all: republish

publish: publish.el
	@echo "Publishing..."
	emacs --batch --load publish.el --funcall kimmy/publish

republish: publish.el
	@echo "Republishing all files..."
	emacs --batch --load publish.el --funcall kimmy/republish

clean:
	@echo "Cleaning up.."
	@rm -rvf *.elc
	@rm -rvf public
	@rm -rvf ~/.org-timestamps/*
