options(width = 150, echo = FALSE)

# Some options for plots

# Name (folder) of the app
app_name    <- "rails_devise"

# Cutoff to determine count of 'slow' responsetimes in milliseconds
slow_cutoff <- 7.5

# Scale of Y axis for full plots
ylim_full   <- c(0, 10)

# Scale of Y axis for detailed plots
ylim_detail <- c(0.5, 4)

# Dimensions for all plots in pixels
width       <- 1920
height      <- 1080

# Histogram
show_uri    <- 4           # Select only one uri for easier to read histograms
ylim_hist   <- c(1, 3) # Limit range to most common response-times

# Start of script #

# Load data from csv
data <- read.csv(
  file   = paste0("data/", app_name, "/measurements.csv"),
  header = TRUE,
  sep    = ",")

data$version <- as.factor(data$version)
versions <- sort(unique(data$version))

# Print some statistics, to be read by the Ruby script
cat(paste0("\nSlow request counts ", slow_cutoff, "\n"))
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

# Get name and value of lowest mean
mm <- aggregate(y ~ version, data = data[data$x > half_x, ], mean)
lowest_mean <- min(mm$y)
lowest_mean_name <- as.character(mm[mm$y == lowest_mean, ]$version)

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

# Histograms
png(
  file   = paste0("data/", app_name, "/plots/", app_name, "_01_histogram.png"),
  width  = width,
  height = height)

par(mfrow = c(ceiling(length(versions) / 3), 3), mar = c(7, 4, 4, 2))

ylim <- length(data$y) / length(versions) / 40
for (i in seq_len(length(versions))) {
  df <- data[data$x > half_x & data$version == versions[i] & data$uri == show_uri, ]

  hist(
    df[df$y <= ylim_hist[2], ]$y,
    breaks = seq(from = 0, to = ylim_hist[2], by = 0.05),
    freq   = TRUE,
    xlim   = ylim_hist,
    ylim   = c(0, ylim),
    col    = "blue",
    border = "white",
    main   = df[1, 1],
    ylab   = NULL,
    xlab   = "response time (ms)")

  abline(v = lowest_median, col = "red", lwd = 1)
}

mtext(
  paste(
    "Lowest mean time:",
    round(lowest_mean, 2),
    "ms",
    "for",
    lowest_mean_name,
    " "),
  side = 1,
  line = -2,
  adj = 1,
  outer = TRUE)

shown_perc <- 100 * nrow(
  data[data$uri == show_uri & data$y >= ylim_hist[1] & data$y <= ylim_hist[2], ]
) / nrow(data[data$uri == show_uri, ])

mtext(
  paste(
    "Shown: URI #",
    show_uri,
    "& ~",
    round(shown_perc, 1),
    "% of measurements for this URI"),
  side = 1,
  line = -2,
  adj = 0,
  outer = TRUE)

dev.off()
par(mfrow = c(1, 1), mar = c(5, 4, 4, 2))

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
  if (TRUE) {
    gc <- df$x[df$mgc == 1 & df$run == 1]

    if (length(gc) <= 100) {
      for (i in seq_len(length(gc))) {
        segments(
          gc[i], ylim_detail[1] / 2,
          gc[i], ylim_detail[1],
          col = "blue",
          lwd = 2)
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
