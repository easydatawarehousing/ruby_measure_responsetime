options(width = 150, echo = FALSE)

# Dimensions for all plots
width  <- 1920
height <- 1080

rodauth <- read.csv(
  file   = "data/rodauth/measurements.csv",
  header = TRUE,
  sep    = ",")

rodauth$version <- as.factor(rodauth$version)
versions <- sort(unique(rodauth$version))

# Boxplot showing all rubies
png(
  file   = "data/rodauth/plots/rodauth_0_overview.png",
  width  = width,
  height = height)

lim_y <- ceiling(sort(rodauth$y)[length(rodauth$x) * 0.99])
boxplot(y ~ version, data = rodauth, ylim = c(0, lim_y), pch = 19, cex = 0.2)

# Print some statistics
cat("\nSlow request counts\n")
aggregate(y ~ version, data = rodauth[rodauth$y >= 5, ], length)

cat("\nMeans\n")
half_x <- max(rodauth$x) / 2
aggregate(y ~ version, data = rodauth[rodauth$x > half_x, ], mean)

cat("\nMedians\n")
aggregate(y ~ version, data = rodauth[rodauth$x > half_x, ], median)

cat("\nCount\n")
aggregate(y ~ version, data = rodauth, length)
cat("\n")

# One full(-ish) scale plot per Ruby
ylim <- c(0, 15)
for (i in seq_len(length(versions))) {
  df <- rodauth[rodauth$version == versions[i], ]

  png(
    file   = paste0("data/rodauth/plots/rodauth_1_", df[1, 1], ".png"),
    width  = width,
    height = height)

  plot(
    df$y ~ df$x,
    pch  = 19,
    cex  = 0.2,
    ylim = ylim,
    col  = df$uri,
    xlab = "Run",
    ylab = "milliseconds",
    main = df[1, 1])

  text(
    half_x,
    ylim[2],
    paste(length(df[df$y > ylim[2], ]$y), "measurements[ y >", ylim[2], "]"),
    pos = 1,
    col = "blue")

  a <- mean(df[df$x > half_x, ]$y)
  if (is.finite(a)) {
    text(
      0,
      ylim[1],
      paste0("Mean time [x > ", half_x, "]: ", round(a, 2), "ms"),
      pos = 4,
      col = "black")

    abline(a = a, b = 0, col = "black", lwd = 3)
  }

  a <- median(df[df$x > half_x,]$y)
  if (is.finite(a)) {
    text(
      half_x,
      ylim[1],
      paste0("Median time [x > ", half_x, "]: ", round(a, 2), "ms"),
      pos = 4,
      col = "red")

    abline(a = a, b = 0, col = "red", lwd = 3)
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

  dev.off()
}

# One detail plot per Ruby
ylim <- c(0.5, 2.5)
for (i in seq_len(length(versions))) {
  df <- rodauth[rodauth$version == versions[i], ]

  png(
    file   = paste0("data/rodauth/plots/rodauth_2_", df[1, 1], ".png"),
    width  = width,
    height = height)

  plot(
    df$y ~ df$x,
    pch  = 19,
    cex  = 0.2,
    ylim = ylim,
    col  = df$uri,
    xlab = "Run",
    ylab = "milliseconds",
    main = df[1, 1])

  text(
    half_x, ylim[2],
    paste(length(df[df$y > ylim[2], ]$y), "measurements[ y > ", ylim[2], "]"),
    pos = 1,
    col = "blue")

  a <- median(df[df$x > half_x, ]$y)
  if (is.finite(a)) {
    text(
      half_x,
      ylim[1],
      paste0("Median time [x > ", half_x, "]: ", round(a, 2), "ms"),
      pos = 4,
      col = "red")

    abline(a = a, b = 0, col = "red", lwd = 3)
  }

  dev.off()
}
