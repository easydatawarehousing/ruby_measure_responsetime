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
OS: Linux 5.15.0-126-generic #136-Ubuntu SMP Wed Nov 6 10:38:22 UTC 2024 x86_64 GNU/Linux  
CPU: AuthenticAMD AMD Ryzen 7 5800X 8-Core Processor  

## Tested Rubies
| Ruby                      | JIT  | Mem start |   Mem end |   Runtime |      Mean |    Median |   Std.Dev |     Slow |   Errors |        N |  GC runs |
| ------------------------- | ---- | --------: | --------: | --------: | --------: | --------: | --------: |--------: | -------: | -------: | -------: |
| ruby-3.0.4                |      |      67Mb |      90Mb |      561s |    2.23ms |    2.28ms |     0.6ms |      867 |        0 |   750000 |      104 |
| ruby-3.1.3                |      |      67Mb |      86Mb |      535s |    2.13ms |     2.2ms |    0.52ms |      524 |        0 |   750000 |       68 |
| ruby-3.1.3                | YJIT |      79Mb |     112Mb |      467s |    1.85ms |    1.89ms |    0.55ms |      669 |        0 |   750000 |       77 |
| ruby-3.2.2                |      |      75Mb |     101Mb |      524s |    2.09ms |    2.15ms |    0.44ms |      204 |        0 |   750000 |       22 |
| ruby-3.2.2                | YJIT |      83Mb |     131Mb |      425s |    1.69ms |     1.7ms |    0.47ms |      267 |        0 |   750000 |       23 |
| ruby-3.3.1                |      |      73Mb |      91Mb |      520s |    2.08ms |    2.15ms |    0.37ms |       82 |        0 |   750000 |        0 |
| ruby-3.3.1                | YJIT |      78Mb |     116Mb |      378s |     1.5ms |    1.51ms |    0.36ms |      128 |        0 |   750000 |        1 |
| ruby-3.4.1                |      |      68Mb |      92Mb |      544s |    2.16ms |    2.19ms |     0.4ms |      111 |        0 |   750000 |        8 |
| ruby-3.4.1                | YJIT |      75Mb |     115Mb |      394s |    1.57ms |    1.53ms |    0.44ms |      154 |        0 |   750000 |        1 |

## Winners

- Ruby with lowest __slow__ response-count (> 7ms): __ruby-3.3.1__ (82x)
- Ruby with lowest __median__* response-time: __ruby-3.3.1 YJIT__ (1.51ms)
- Ruby with lowest __standard deviation__ response-time: __ruby-3.3.1 YJIT__ (0.36ms)
- Ruby with lowest __mean__* response-time: __ruby-3.3.1 YJIT__ (1.5ms)
- Ruby with lowest __memory__ use: __ruby-3.1.3__ (86Mb)

\* Mean and median are calculated after warmup (x > N/2).

## Overview of response-times of all tested Rubies
[Boxplot](https://en.wikipedia.org/wiki/Box_plot) showing ~99% of all measurements (sorted by responsetime)
![Overview of response-times of all tested Rubies](/data/rails_devise/plots/rails_devise_0_overview.png "Overview of response-times of all tested Rubies")

## Histograms of response-times of all tested Rubies
Showing a single tested uri and the most occurring response-times after warmup (x > N/2)
![Histograms of response-times of all tested Rubies](/data/rails_devise/plots/rails_devise_0_histogram.png "Histograms of response-times of all tested Rubies")

## Memory use of all tested Rubies
Logged after a fixed interval of measurements (1,000). Each run is shown in a different color
![Memory use of all tested Rubies](/data/rails_devise/plots/rails_devise_0_memory.png "Memory use of all tested Rubies")

## Scatter-plots
These scatter-plots show the response time of individual calls as dots. Note that many dots may overlap each other.  
Vertical blue lines near the X-axis indicate major garbage collection runs (of Run-ID 1, but only when there are less than 100 GC runs).
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

## Response-times for: ruby-3.3.1
![Response-times for: ruby-3.3.1](/data/rails_devise/plots/rails_devise_1_ruby-3.3.1.png "Response-times for: ruby-3.3.1")

## Response-times for: ruby-3.3.1 YJIT
![Response-times for: ruby-3.3.1 YJIT](/data/rails_devise/plots/rails_devise_1_ruby-3.3.1%20YJIT.png "Response-times for: ruby-3.3.1 YJIT")

## Response-times for: ruby-3.4.1
![Response-times for: ruby-3.4.1](/data/rails_devise/plots/rails_devise_1_ruby-3.4.1.png "Response-times for: ruby-3.4.1")

## Response-times for: ruby-3.4.1 YJIT
![Response-times for: ruby-3.4.1 YJIT](/data/rails_devise/plots/rails_devise_1_ruby-3.4.1%20YJIT.png "Response-times for: ruby-3.4.1 YJIT")


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

## Detailed response-times for: ruby-3.3.1
![Detailed response-times for: ruby-3.3.1](/data/rails_devise/plots/rails_devise_2_ruby-3.3.1.png "Detailed response-times for: ruby-3.3.1")

## Detailed response-times for: ruby-3.3.1 YJIT
![Detailed response-times for: ruby-3.3.1 YJIT](/data/rails_devise/plots/rails_devise_2_ruby-3.3.1%20YJIT.png "Detailed response-times for: ruby-3.3.1 YJIT")

## Detailed response-times for: ruby-3.4.1
![Detailed response-times for: ruby-3.4.1](/data/rails_devise/plots/rails_devise_2_ruby-3.4.1.png "Detailed response-times for: ruby-3.4.1")

## Detailed response-times for: ruby-3.4.1 YJIT
![Detailed response-times for: ruby-3.4.1 YJIT](/data/rails_devise/plots/rails_devise_2_ruby-3.4.1%20YJIT.png "Detailed response-times for: ruby-3.4.1 YJIT")

