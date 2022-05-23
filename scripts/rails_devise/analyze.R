options(width = 150, echo = FALSE)

# Name (folder) of the app
app_name    <- "rails_devise"

# Cutoff to determine count of 'slow' responsetimes in milliseconds
slow_cutoff <- 7.5

# Scale of Y axis for full plots
ylim_full   <- c(0, 25)

# Scale of Y axis for detailed plots
ylim_detail <- c(2.5, 12.5)

# Dimensions for all plots in pixels
width       <- 1920
height      <- 1080

# Load data from csv
data <- read.csv(
  file   = paste0("data/", app_name, "/measurements.csv"),
  header = TRUE,
  sep    = ",")

data$version <- as.factor(data$version)
versions <- sort(unique(data$version))

# Print some statistics, to be read by the Ruby script
cat("\nSlow request counts\n")
aggregate(y ~ version, data = data[data$y >= slow_cutoff, ], length)

cat("\nMeans\n")
half_x <- max(data$x) / 2
aggregate(y ~ version, data = data[data$x > half_x, ], mean)

cat("\nMedians\n")
aggregate(y ~ version, data = data[data$x > half_x, ], median)

cat("\nCount\n")
aggregate(y ~ version, data = data, length)

cat("\nSD\n")
aggregate(y ~ version, data = data, sd)

cat("\n")

# Get name and value of lowest median
mm <- aggregate(y ~ version, data = data[data$x > half_x, ], median)
lowest_median <- min(mm$y)
lowest_median_name <- as.character(mm[mm$y == lowest_median, ]$version)

# Boxplot showing all rubies
png(
  file   = paste0("data/", app_name, "/plots/", app_name, "_0_overview.png"),
  width  = width,
  height = height)

lim_y <- ceiling(sort(data$y)[length(data$x) * 0.99])
boxplot(y ~ version, data = data, ylim = c(0, lim_y), pch = 19, cex = 0.2)
abline(a = lowest_median, b = 0, col = "red", lwd = 3)
text(
  1,
  0,
  paste0(
    "Lowest median time [x > ",
    half_x,
    "] for ",
    lowest_median_name,
    ": ",
    round(lowest_median, 2),
    "ms"),
  pos = 4,
  col = "black")

# One 'full' scale plot per Ruby
for (i in seq_len(length(versions))) {
  df <- data[data$version == versions[i], ]

  png(
    file = paste0(
      "data/",
      app_name,
      "/plots/",
      app_name,
      "_1_",
      df[1, 1],
      ".png"),
    width  = width,
    height = height)

  plot(
    df$y ~ df$x,
    pch  = 19,
    cex  = 0.2,
    ylim = ylim_full,
    col  = df$uri,
    xlab = "Run",
    ylab = "milliseconds",
    main = df[1, 1])

  text(
    half_x,
    ylim_full[2],
    paste(
      length(df[df$y > ylim_full[2], ]$y),
      "measurements[ y >",
      ylim_full[2],
      "]"),
    pos = 1,
    col = "blue")

  a <- median(df[df$x > half_x, ]$y)
  if (is.finite(a)) {
    text(
      0,
      ylim_full[1],
      paste0("Median time [x > ", half_x, "]: ", round(a, 2), "ms"),
      pos = 4,
      col = "black")

    abline(a = a, b = 0, col = "black", lwd = 3)
  }

  if (is.finite(lowest_median)) {
    text(
      half_x,
      ylim_full[1],
      paste0(
        "Lowest median time [x > ",
        half_x,
        "] for ",
        lowest_median_name,
        ": ",
        round(lowest_median, 2),
        "ms"),
      pos = 4,
      col = "red")

    abline(a = lowest_median, b = 0, col = "red", lwd = 3)
  }

  # Set value to TRUE if you want add vertical lines
  # indicating a major garbage collection run
  if (FALSE) {
    gc <- df$x[df$mgc == 1]
    if (length(gc) <= 50) {
      for (i in seq_len(length(gc))) {
        abline(v = gc[i], col = "blue", lwd = 0.5)
      }
    }
  }

  # Save the plot
  dev.off()
}

# One detail plot per Ruby
for (i in seq_len(length(versions))) {
  df <- data[data$version == versions[i], ]

  png(
    file = paste0(
      "data/",
      app_name,
      "/plots/",
      app_name,
      "_2_",
      df[1, 1],
      ".png"),
    width  = width,
    height = height)

  plot(
    df$y ~ df$x,
    pch  = 19,
    cex  = 0.2,
    ylim = ylim_detail,
    col  = df$uri,
    xlab = "Run",
    ylab = "milliseconds",
    main = df[1, 1])

  text(
    half_x, ylim_detail[2],
    paste(
      length(df[df$y > ylim_detail[2], ]$y),
      "measurements[ y > ",
      ylim_detail[2],
      "]"),
    pos = 1,
    col = "blue")

  if (is.finite(lowest_median)) {
    text(
      half_x,
      ylim_detail[1],
      paste0(
        "Lowest median time [x > ",
        half_x,
        "] for ",
        lowest_median_name,
        ": ",
        round(lowest_median, 2),
        "ms"),
      pos = 4,
      col = "red")

    abline(a = lowest_median, b = 0, col = "red", lwd = 3)
  }

  # Save the plot
  dev.off()
}
