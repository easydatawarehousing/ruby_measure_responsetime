# Analysis app 'rails_devise'
This is a test application based on [Ruby-on-Rails](https://rubyonrails.org/),
using [Devise](https://github.com/heartcombo/devise) for authentication.

Performance of this application was tested by continuously sending requests to the server.
Five url's were included in the test:

1. index-page without cookie (black)
2. create-account-page (red)
3. reset-password-request-page (green)
4. index-page with good cookie (blue)
5. index-page with bad cookie (cyan)

## System
OS: Linux 5.15.0-91-generic #101-Ubuntu SMP Tue Nov 14 13:30:08 UTC 2023 x86_64 GNU/Linux  
CPU: AuthenticAMD AMD Ryzen 7 5800X 8-Core Processor  

## Tested Rubies
| Ruby                      | JIT  | Mem start |   Mem end |   Runtime |      Mean |    Median |   Std.Dev |     Slow |   Errors |        N |  GC runs |
| ------------------------- | ---- | --------: | --------: | --------: | --------: | --------: | --------: |--------: | -------: | -------: | -------: |
| ruby-3.0.4                |      |      65Mb |      88Mb |      554s |    2.25ms |    2.26ms |    0.66ms |      892 |        0 |   750000 |      116 |
| ruby-3.1.3                |      |      66Mb |      85Mb |      536s |    2.15ms |    2.18ms |    0.56ms |      632 |        0 |   750000 |       81 |
| ruby-3.1.3                | YJIT |      81Mb |     113Mb |      470s |    1.86ms |    1.88ms |    0.48ms |      475 |        0 |   750000 |       48 |
| ruby-3.2.2                |      |      70Mb |      93Mb |      517s |    2.06ms |    2.11ms |    0.44ms |      285 |        0 |   750000 |       30 |
| ruby-3.2.2                | YJIT |      81Mb |     130Mb |      419s |    1.69ms |    1.68ms |    0.43ms |      252 |        0 |   750000 |       20 |
| ruby-3.3.0                |      |      70Mb |      88Mb |      523s |    2.09ms |    2.12ms |    0.41ms |      111 |        0 |   750000 |        0 |
| ruby-3.3.0                | YJIT |      78Mb |     116Mb |      372s |    1.47ms |    1.48ms |    0.35ms |      128 |        0 |   750000 |        1 |

## Winners

- Ruby with lowest __slow__ response-count (> 7ms): __ruby-3.3.0__ (111x)
- Ruby with lowest __median__* response-time: __ruby-3.3.0 YJIT__ (1.48ms)
- Ruby with lowest __standard deviation__ response-time: __ruby-3.3.0 YJIT__ (0.35ms)
- Ruby with lowest __mean__* response-time: __ruby-3.3.0 YJIT__ (1.47ms)
- Ruby with lowest __memory__ use: __ruby-3.1.3__ (85Mb)

\* Mean and median are calculated after warmup (x > N/2).

## Overview of response-times of all tested Rubies
[Boxplot](https://en.wikipedia.org/wiki/Box_plot) showing ~99% of all measurements (sorted by responsetime)
![Overview of response-times of all tested Rubies](/data/rails_devise/plots/rails_devise_0_overview.png "Overview of response-times of all tested Rubies")

## Histograms of response-times of all tested Rubies
Showing a single tested uri and the most occurring response-times after warmup (x > N/2)
![Histograms of response-times of all tested Rubies](/data/rails_devise/plots/rails_devise_01_histogram.png "Histograms of response-times of all tested Rubies")

## Scatter-plots
These scatter-plots show the response time of individual calls as dots. Note that many dots may overlap each other.  
Vertical blue lines near the X-axis indicate major garbage collection runs (of Run-ID 1, only when there are less than 100 GC runs).
## Response-times for: ruby-3.0.4
![Response-times for: ruby-3.0.4](/data/rails_devise/plots/rails_devise_1_ruby-3.0.4.png "Response-times for: ruby-3.0.4")

## Response-times for: ruby-3.1.3
![Response-times for: ruby-3.1.3](/data/rails_devise/plots/rails_devise_1_ruby-3.1.3.png "Response-times for: ruby-3.1.3")

## Response-times for: ruby-3.1.3 YJIT
![Response-times for: ruby-3.1.3 YJIT](/data/rails_devise/plots/rails_devise_1_ruby-3.1.3%20YJIT.png "Response-times for: ruby-3.1.3 YJIT")

## Response-times for: ruby-3.2.2
![Response-times for: ruby-3.2.2](/data/rails_devise/plots/rails_devise_1_ruby-3.2.2.png "Response-times for: ruby-3.2.2")

## Response-times for: ruby-3.2.2 YJIT
![Response-times for: ruby-3.2.2 YJIT](/data/rails_devise/plots/rails_devise_1_ruby-3.2.2%20YJIT.png "Response-times for: ruby-3.2.2 YJIT")

## Response-times for: ruby-3.3.0
![Response-times for: ruby-3.3.0](/data/rails_devise/plots/rails_devise_1_ruby-3.3.0.png "Response-times for: ruby-3.3.0")

## Response-times for: ruby-3.3.0 YJIT
![Response-times for: ruby-3.3.0 YJIT](/data/rails_devise/plots/rails_devise_1_ruby-3.3.0%20YJIT.png "Response-times for: ruby-3.3.0 YJIT")


## Detailed scatter-plots
Same as above but focussing on the most ocurring response times. GC runs are not shown.
## Detailed response-times for: ruby-3.0.4
![Detailed response-times for: ruby-3.0.4](/data/rails_devise/plots/rails_devise_2_ruby-3.0.4.png "Detailed response-times for: ruby-3.0.4")

## Detailed response-times for: ruby-3.1.3
![Detailed response-times for: ruby-3.1.3](/data/rails_devise/plots/rails_devise_2_ruby-3.1.3.png "Detailed response-times for: ruby-3.1.3")

## Detailed response-times for: ruby-3.1.3 YJIT
![Detailed response-times for: ruby-3.1.3 YJIT](/data/rails_devise/plots/rails_devise_2_ruby-3.1.3%20YJIT.png "Detailed response-times for: ruby-3.1.3 YJIT")

## Detailed response-times for: ruby-3.2.2
![Detailed response-times for: ruby-3.2.2](/data/rails_devise/plots/rails_devise_2_ruby-3.2.2.png "Detailed response-times for: ruby-3.2.2")

## Detailed response-times for: ruby-3.2.2 YJIT
![Detailed response-times for: ruby-3.2.2 YJIT](/data/rails_devise/plots/rails_devise_2_ruby-3.2.2%20YJIT.png "Detailed response-times for: ruby-3.2.2 YJIT")

## Detailed response-times for: ruby-3.3.0
![Detailed response-times for: ruby-3.3.0](/data/rails_devise/plots/rails_devise_2_ruby-3.3.0.png "Detailed response-times for: ruby-3.3.0")

## Detailed response-times for: ruby-3.3.0 YJIT
![Detailed response-times for: ruby-3.3.0 YJIT](/data/rails_devise/plots/rails_devise_2_ruby-3.3.0%20YJIT.png "Detailed response-times for: ruby-3.3.0 YJIT")

