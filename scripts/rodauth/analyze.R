options(width=150, echo=FALSE)

rodauth = read.csv(file="data/rodauth/measurements.csv",  header=TRUE, sep=",")
rodauth$version = as.factor(rodauth$version)
versions = sort(unique(rodauth$version))

# Boxplot showing all rubies
png(file="data/rodauth/plots/rodauth_0_overview.png", width=1920, height=1080)
lim_y = ceiling(sort(rodauth$y)[length(rodauth$x) * 0.99])
boxplot(y ~ version, data = rodauth, ylim=c(0, lim_y), pch=19, cex=0.2)

cat("\nSlow request counts\n")
aggregate(y ~ version, data = rodauth[rodauth$y >= 5,], length)

cat("\nMeans\n")
half_x = max(rodauth$x) / 2
aggregate(y ~ version, data = rodauth[rodauth$x > half_x,], mean)

cat("\nMedians\n")
aggregate(y ~ version, data = rodauth[rodauth$x > half_x,], median)

cat("\nCount\n")
aggregate(y ~ version, data = rodauth, length)
cat("\n")

# One full(-ish) scale plot per Ruby
for(i in 1:length(versions)) {
  df = rodauth[rodauth$version == versions[i],]

  png(file=paste0("data/rodauth/plots/rodauth_1_", df[1, 1],".png"), width=1920, height=1080)

  plot(df$y ~ df$x, pch=19, cex=0.2, ylim=c(0, 15), col=df$uri, xlab="Run", ylab="milliseconds", main=df[1, 1])

  text(half_x, 15, paste(length(df[df$y > 15,]$y), "measurements [y > 15]"), pos=1, col="blue")

  a = mean(df[df$x > half_x,]$y)
  if (is.finite(a)) {
    text(0, 0, paste0("Mean time [x > ", half_x, "]: ", round(a, 2), "ms"), pos=4, col="black")
    abline(a=a, b=0, col="black", lwd=3)
  }

  a = median(df[df$x > half_x,]$y)
  if (is.finite(a)) {
    text(half_x, 0, paste0("Median time [x > ", half_x, "]: ", round(a, 2), "ms"), pos=4, col="red")
    abline(a=a, b=0, col="red", lwd=3)
  }

  # Uncomment next 4 lines if you want vertical lines indicating a major garbage collection run
  # gc = df$x[df$mgc == 1]
  # if (length(gc) <= 50) {
  #   for(i in 1:length(gc)) { abline(v=gc[i], col="blue", lwd=0.5) }
  # }

  dev.off()
}

# One detail plot per Ruby
for(i in 1:length(versions)) {
  df = rodauth[rodauth$version == versions[i],]

  png(file=paste0("data/rodauth/plots/rodauth_2_", df[1, 1],".png"), width=1920, height=1080)

  plot(df$y ~ df$x, pch=19, cex=0.2, ylim=c(0.5, 2.5), col=df$uri, xlab="Run", ylab="milliseconds", main=df[1, 1])

  text(half_x, 2.5, paste(length(df[df$y > 2.5,]$y), "measurements [y > 2.5]"), pos=1, col="blue")

  a = median(df[df$x > half_x,]$y)
  if (is.finite(a)) {
    text(half_x, 0.5, paste0("Median time [x > ", half_x, "]: ", round(a, 2), "ms"), pos=4, col="red")
    abline(a=a, b=0, col="red", lwd=3)
  }

  dev.off()
}
