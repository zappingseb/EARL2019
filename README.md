# RSelenium or shinytest

*How to make shiny apps ready for use in a regulated environment*

![](pptx/photos/image_front2.jpg)
---

Presentation [@EARLconf](https://earlconf.com) on September 12 2019

The code inside this repository contains the following folders with examples

- **shinytest**: An app for Diagnostics quality control and a test case ran by the [shinytest](https://github.com/rstudio/shinytest)-package.
- **RSelenium**: An app for a Pharma study validation report, that is tested with either pure [RSelenium](https://github.com/ropensci/RSelenium)-package or *RSeleniumTest*.
- **pptx**: The slides presented [@EARLconf](https://earlconf.com).
- **balsamique**: Balsamique files to plan the apps to be tested.

### Before looking into the code

Install all dependencies:

```
install.packages(c("shinytest", "tidyverse", "shiny", "XML", "jsonlite", "ggplot2", "ggmosaic"))
```

## shinytest


## RSelenium

### Setup

For my setup I downloaded the [ChromeDriver](https://sites.google.com/a/chromium.org/chromedriver/downloads) and [GheckoDriver](https://github.com/mozilla/geckodriver/releases) for Selenium. Additionally
you will need the [SeleniumServer-Standalone](https://bit.ly/2TlkRyu).

On my PC
I stored them under: `C:\Programme_2\RSelenium`. You will see this address a lot
of times in the code. If you want an easy way of working, I recommend storing your
code there, too.

### The App

