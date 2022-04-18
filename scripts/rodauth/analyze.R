# Colors used:
# 1=black  = index-page without cookie
# 2=red    = create-account-page
# 3=green  = reset-password-request-page
# 4=blue   = index-page with good cookie
# 5=cyan   = index-page with bad cookie

# library(RColorBrewer)
# display.brewer.all()
# display.brewer.all(n = 5, colorblindFriendly = TRUE)
# brewer.pal(n = 5, name = "Dark2")
#
# col=brewer.pal(n = 5, name = "BrBG")[df$uri]

options(width=150, echo=FALSE)
# system("clear")
rodauth = read.csv(file="data/rodauth/measurements.csv",  header=TRUE, sep=",")
rodauth$version = as.factor(rodauth$version)
versions = sort(unique(rodauth$version))
summary(rodauth, maxsum = length(versions))

# Boxplot showing all rubies
png(file=paste0("data/rodauth/plots/rodauth_0_overview.png"), width=1920, height=1080)
boxplot(y ~ version, data = rodauth[rodauth$y < 20,], pch=19, cex=0.2)

cat("\nSlow request counts\n")
aggregate(y ~ version, data = rodauth[rodauth$y >= 5,], length)
cat("\nMeans\n")
aggregate(y ~ version, data = rodauth, mean)
cat("\nMedians\n")
aggregate(y ~ version, data = rodauth, median)
cat("\n")

# One full scale plot per Ruby
for(i in 1:length(versions)) {
  df = rodauth[rodauth$version == versions[i],]
  cat("Plotting:", paste(df[1, 1], "\n"))

  png(file=paste0("data/rodauth/plots/rodauth_1_", df[1, 1],".png"), width=1920, height=1080)

  plot(df$y ~ df$x, pch=19, cex=0.2, ylim=c(0, 15), col=df$uri, xlab="Run", ylab="milliseconds", main=df[1, 1])

  xpos = length(df$y) / 10
  text(xpos, 15, paste(length(df[df$y > 15,]$y), "measurements [y > 15]"), pos=1, col="blue")

  a = mean(df$y)
  text(0, 0, paste("Mean time:", round(a, 2), "ms"), pos=4, col="black")
  abline(a=a, b=0, col="black", lwd=3)

  a = median(df$y)
  text(xpos, 0, paste("Median time:", round(a, 2), "ms"), pos=4, col="red")
  abline(a=a, b=0, col="red", lwd=3)

  # Uncomment next 4 lines if you want vertical lines indicating a major garbage collection run
  # gc = df$x[df$mgc == 1 & df$uri == 0]
  # if (length(gc) <= 50) {
  #   for(i in 1:length(gc)) { abline(v=gc[i], col="blue", lwd=0.5) }
  # }

  dev.off()
}

# One detail plot per Ruby
for(i in 1:length(versions)) {
  df = rodauth[rodauth$version == versions[i],]
  cat("Detail plot:", paste(df[1, 1], "\n"))

  png(file=paste0("data/rodauth/plots/rodauth_detail_2_", df[1, 1],".png"), width=1920, height=1080)

  plot(df$y ~ df$x, pch=19, cex=0.2, ylim=c(0.5, 2.5), col=df$uri, xlab="Run", ylab="milliseconds", main=df[1, 1])

  xpos = length(df$y) / 10
  text(xpos, 2.5, paste(length(df[df$y > 2.5,]$y), "measurements [y > 2.5]"), pos=1, col="blue")

  a = median(df$y)
  text(xpos, 0.5, paste("Median time:", round(a, 2), "ms"), pos=4, col="red")
  abline(a=a, b=0, col="red", lwd=3)

  dev.off()
}
