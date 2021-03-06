
lines <- c(
  " 1M 1.45Rotterdam ",
  " 2F12.00Amsterdam ",
  " 3  .22 Berlin    ",
  "  M22   Paris     ",
  " 4F12345London    ",
  " 5M     Copenhagen",
  " 6M-12.1          ",
  " 7F   -1Oslo      ")
 
data <- data.frame(
      id=c(1,2,3,NA,4,5,6,7),
      gender=as.factor(c("M", "F", NA, "M", "F", "M", "M", "F")),
      x=c(1.45, 12, 0.22, 22, 12345, NA, -12.1, -1),
      city=c("Rotterdam", "Amsterdam", "Berlin", "Paris", 
          "London", "Copenhagen", "", "Oslo"),
      stringsAsFactors=FALSE
    )

context("Reading of fixed width file using blockwise operators")

test_that("reading all data works (\\n end-of-line)", {
  tmpfwf <- tempfile()
  writeLines(lines, con=tmpfwf, sep="\n")
  laf <- laf_open_fwf(filename=tmpfwf, 
      column_types=c("integer", "categorical", "double", "string"),
      column_widths=c(2,1,5,10)
      )
  testdata <- laf[]
  expect_that(testdata[,1], equals(data[,1]))
  expect_that(sort(levels(testdata[[2]])), equals(c("F", "M")))
  expect_that(as.character(testdata[,2]), equals(as.character(data[,2])))
  expect_that(testdata[,3], equals(data[,3]))
  expect_that(testdata[,4], equals(data[,4]))
  expect_that(is.na(testdata[4,1]), is_true())
  expect_that(is.na(testdata[3,2]), is_true())
  expect_that(is.na(testdata[6,3]), is_true())
  file.remove(tmpfwf)
})

test_that("reading all data works (\\r\\n end-of-line)", {
  tmpfwf <- tempfile()
  writeLines(lines, con=tmpfwf, sep="\r\n")
  laf <- laf_open_fwf(filename=tmpfwf, 
      column_types=c("integer", "categorical", "double", "string"),
      column_widths=c(2,1,5,10)
      )
  testdata <- laf[]
  expect_that(testdata[,1], equals(data[,1]))
  expect_that(sort(levels(testdata[[2]])), equals(c("F", "M")))
  expect_that(as.character(testdata[,2]), equals(as.character(data[,2])))
  expect_that(testdata[,3], equals(data[,3]))
  expect_that(testdata[,4], equals(data[,4]))
  expect_that(is.na(testdata[4,1]), is_true())
  expect_that(is.na(testdata[3,2]), is_true())
  expect_that(is.na(testdata[6,3]), is_true())
  file.remove(tmpfwf)
})

test_that("reading all data works (\\n end-of-line; extra newline)", {
  tmpfwf <- tempfile()
  writeLines(c(lines,""), con=tmpfwf, sep="\n")
  laf <- laf_open_fwf(filename=tmpfwf, 
      column_types=c("integer", "categorical", "double", "string"),
      column_widths=c(2,1,5,10)
      )
  testdata <- laf[]
  expect_that(testdata[,1], equals(data[,1]))
  expect_that(sort(levels(testdata[[2]])), equals(c("F", "M")))
  expect_that(as.character(testdata[,2]), equals(as.character(data[,2])))
  expect_that(testdata[,3], equals(data[,3]))
  expect_that(testdata[,4], equals(data[,4]))
  expect_that(is.na(testdata[4,1]), is_true())
  expect_that(is.na(testdata[3,2]), is_true())
  expect_that(is.na(testdata[6,3]), is_true())
  file.remove(tmpfwf)
})

test_that("reading all data works (\\n end-of-line; , decimal)", {
  tmpfwf <- tempfile()
  writeLines(gsub("\\.", ",", lines), con=tmpfwf, sep="\n")
  laf <- laf_open_fwf(filename=tmpfwf, dec=",",
      column_types=c("integer", "categorical", "double", "string"),
      column_widths=c(2,1,5,10)
      )
  testdata <- laf[]
  expect_that(testdata[,1], equals(data[,1]))
  expect_that(testdata[,3], equals(data[,3]))
  expect_that(sort(levels(testdata[[2]])), equals(c("F", "M")))
  expect_that(as.character(testdata[,2]), equals(as.character(data[,2])))
  expect_that(testdata[,4], equals(data[,4]))
  expect_that(is.na(testdata[4,1]), is_true())
  expect_that(is.na(testdata[3,2]), is_true())
  expect_that(is.na(testdata[6,3]), is_true())
  file.remove(tmpfwf)
})


test_that("process_blocks works", {
  tmpfwf <- tempfile()
  writeLines(lines, con=tmpfwf, sep="\n")
  laf <- laf_open_fwf(filename=tmpfwf, 
      column_types=c("integer", "categorical", "double", "string"),
      column_widths=c(2,1,5,10)
      )
  calc_sum <- function(d, r) {
      if (is.null(r)) r <- 0
      r <- r + sum(d[,1], na.rm=TRUE)
  }
  expect_that(process_blocks(laf, calc_sum, columns=1), equals(sum(data[,1], na.rm=TRUE)))
  expect_that(process_blocks(laf, calc_sum, columns=3), equals(sum(data[,3], na.rm=TRUE)))
  file.remove(tmpfwf)
})

