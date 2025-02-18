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
install.packages(c("shinytest", "tidyverse", "shiny", "XML", "jsonlite", "ggplot2", "ggmosaic", "callr", "testthat"))
```

## shinytest

### Setup

To use shinytest it is enough to install the package [shinytest](https://github.com/rstudio/shinytest). You might have
difficulties installing phantomjs, which is needed. But you can
do an online-search on this problem.

### The App

The Diagnostics App uses CSV data that has to come in a specific format. In
every column there are measurements from a different chemical. The
first column is the reference chemical. Now we want to know by the difference
of means and an F-Test, if the other chemicals are ok in quality control and
can go to the market. The app just allows the user to select the CSV
with the data and the chemicals to be tested.

![](pptx/photos/dia_app.png)

### The Recorder

Shinytest comes with a test recorder. The test recorder allows you to start
the app and do some basic interactions. Here you can see, that the file is uploaded and columns 1, 2 and 3 are getting selected.

![](pptx/photos/shinytest.gif)

### Files

`app.R`

This contains the shiny-App to run.

`tests/mytest.R`

This file is an extension of the file provided by the recorder. Instead of
just changing the inputs, the snapshots get analyzed. The testing script
compares any output in the F-Test, summary table or Mean-Test against
reference values.

As you can see, reference values are stored within the script.

TEST1 vs TEST2 shall be ok, while TEST1 vs TEST3 shall not be ok.

## RSelenium

### Setup

For my setup I downloaded the [ChromeDriver](https://sites.google.com/a/chromium.org/chromedriver/downloads) and [GheckoDriver](https://github.com/mozilla/geckodriver/releases) for Selenium. Additionally
you will need the [SeleniumServer-Standalone](https://bit.ly/2TlkRyu).

On my PC
I stored them under: `C:\Programme_2\RSelenium`. You will see this address a lot
of times in the code. If you want an easy way of working, I recommend storing your
code there, too.

You will need Java > v8 to run Selenium.

### The App

The app showing Pharma data shall be used for stakeholders
checking clinical studies.

![](pptx/photos/app_pharma.png)

 Inside the Pharma App we build a drag&drop to allow users to define what they want to plot. The plot shall be tested by image comparison.

As this app is for non-statisticians, there is also a help build in which shall be tested. Even if here, the help does not contain anything.

Moreover a data-table should ensure that data is not changed form input to output.

App parts:

- Drag and drop for variables
- Opens pop-up with on hover on help
- hidden input value
- Data table
- should run on multiple sites (asia Chrome / Europe Firefox)

### Files

`app.R`

Contains the app Code itself. You can simply run the app and play
around by opening it in RStudio. It is recommended to run the
app in Chrome or Firefox.

`test.app.R`

Starts the app via `callr` in a second session. Starts a Selenium Standalone
server, runs a clicktests in Firefox, stops the app and the Selenium Server.

`test.app.RSeleniumTest.R`

This script just runs on my computer. For disclosure reasons the package
`RSeleniumTest` is not open-sourced, yet. It basically uses the
package [RTest](https://github.com/zappingseb/RTest) with an adapter. It uses the
two XML files `TC-RSelenium-MicroTest-chrome.xml` and `TC-RSelenium-MicroTest-firefox.xml` to test the app.

### Note

If you are not running in Windows, please start Selenium as described in the vignettes of [RSelenium](https://github.com/ropensci/RSelenium).
