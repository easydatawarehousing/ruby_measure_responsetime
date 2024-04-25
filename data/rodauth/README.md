# Analysis app 'rodauth'
This is a test application based on [roda-sequel-stack](https://github.com/jeremyevans/roda-sequel-stack.git),
using [Roda](https://github.com/jeremyevans/roda) as the web framework,
[Sequel](https://github.com/jeremyevans/sequel) as the database library
and [Rodauth](https://github.com/jeremyevans/rodauth) for authentication.

Performance of this application was tested by continuously sending requests to the server.
Five url's were included in the test:

1. index-page without cookie (black)
2. create-account-page (red)
3. reset-password-request-page (green)
4. index-page with good cookie (blue)
5. index-page with bad cookie (cyan)

## System
OS: Linux 5.15.0-105-generic #115-Ubuntu SMP Mon Apr 15 09:52:04 UTC 2024 x86_64 GNU/Linux  
CPU: AuthenticAMD AMD Ryzen 7 5800X 8-Core Processor  

## Tested Rubies
| Ruby                      | JIT  | Mem start |   Mem end |   Runtime |      Mean |    Median |   Std.Dev |     Slow |   Errors |        N |  GC runs |
| ------------------------- | ---- | --------: | --------: | --------: | --------: | --------: | --------: |--------: | -------: | -------: | -------: |
| ruby-3.0.4                |      |      34Mb |      45Mb |      141s |    0.56ms |    0.55ms |    0.14ms |      354 |        0 |   750000 |       48 |
| ruby-3.1.3                |      |      37Mb |      46Mb |      153s |     0.6ms |    0.56ms |    0.49ms |     5176 |        0 |   750000 |      983 |
| ruby-3.1.3                | YJIT |      47Mb |      61Mb |      154s |    0.61ms |    0.59ms |    0.18ms |      417 |        0 |   750000 |       49 |
| ruby-3.2.2                |      |      37Mb |      51Mb |      124s |    0.49ms |    0.47ms |    0.12ms |       99 |        0 |   750000 |       19 |
| ruby-3.2.2                | MJIT |      37Mb |      51Mb |      125s |    0.49ms |    0.47ms |    0.12ms |       93 |        0 |   750000 |       19 |
| ruby-3.2.2                | YJIT |      38Mb |      57Mb |      113s |    0.45ms |    0.42ms |    0.16ms |      147 |        0 |   750000 |       22 |
| ruby-3.3.0                |      |      41Mb |     133Mb |      138s |    0.55ms |    0.53ms |    0.13ms |        9 |        0 |   750000 |        1 |
| ruby-3.3.0                | RJIT |      82Mb |     295Mb |      142s |    0.55ms |    0.49ms |     2.9ms |     5302 |        0 |   750000 |        2 |
| ruby-3.3.0                | YJIT |      42Mb |     139Mb |      119s |    0.48ms |    0.46ms |    0.18ms |       27 |        0 |   750000 |        1 |
| ruby-3.3.1                |      |      39Mb |      46Mb |      136s |    0.54ms |    0.52ms |    0.12ms |        9 |        0 |   750000 |        4 |
| ruby-3.3.1                | RJIT |      74Mb |     195Mb |      143s |    0.56ms |    0.49ms |    2.91ms |     4351 |        0 |   750000 |        2 |
| ruby-3.3.1                | YJIT |      40Mb |      52Mb |      117s |    0.46ms |    0.44ms |    0.18ms |       25 |        0 |   750000 |        1 |

## Winners

- Ruby with lowest __slow__ response-count (> 3ms): __ruby-3.3.0__ (9x)
- Ruby with lowest __median__* response-time: __ruby-3.2.2 YJIT__ (0.42ms)
- Ruby with lowest __standard deviation__ response-time: __ruby-3.2.2__ (0.12ms)
- Ruby with lowest __mean__* response-time: __ruby-3.2.2 YJIT__ (0.45ms)
- Ruby with lowest __memory__ use: __ruby-3.0.4__ (45Mb)

\* Mean and median are calculated after warmup (x > N/2).

## Overview of response-times of all tested Rubies
[Boxplot](https://en.wikipedia.org/wiki/Box_plot) showing ~99% of all measurements (sorted by responsetime)
![Overview of response-times of all tested Rubies](/data/rodauth/plots/rodauth_0_overview.png "Overview of response-times of all tested Rubies")

## Histograms of response-times of all tested Rubies
Showing a single tested uri and the most occurring response-times after warmup (x > N/2)
![Histograms of response-times of all tested Rubies](/data/rodauth/plots/rodauth_0_histogram.png "Histograms of response-times of all tested Rubies")

## Memory use of all tested Rubies
Logged after a fixed interval of measurements (1,000). Each run is shown in a different color
![Memory use of all tested Rubies](/data/rodauth/plots/rodauth_0_memory.png "Memory use of all tested Rubies")

## Scatter-plots
These scatter-plots show the response time of individual calls as dots. Note that many dots may overlap each other.  
Vertical blue lines near the X-axis indicate major garbage collection runs (of Run-ID 1, but only when there are less than 100 GC runs).
## Response-times for: ruby-3.0.4
![Response-times for: ruby-3.0.4](/data/rodauth/plots/rodauth_1_ruby-3.0.4.png "Response-times for: ruby-3.0.4")

## Response-times for: ruby-3.1.3
![Response-times for: ruby-3.1.3](/data/rodauth/plots/rodauth_1_ruby-3.1.3.png "Response-times for: ruby-3.1.3")

## Response-times for: ruby-3.1.3 YJIT
![Response-times for: ruby-3.1.3 YJIT](/data/rodauth/plots/rodauth_1_ruby-3.1.3%20YJIT.png "Response-times for: ruby-3.1.3 YJIT")

## Response-times for: ruby-3.2.2
![Response-times for: ruby-3.2.2](/data/rodauth/plots/rodauth_1_ruby-3.2.2.png "Response-times for: ruby-3.2.2")

## Response-times for: ruby-3.2.2 MJIT
![Response-times for: ruby-3.2.2 MJIT](/data/rodauth/plots/rodauth_1_ruby-3.2.2%20MJIT.png "Response-times for: ruby-3.2.2 MJIT")

## Response-times for: ruby-3.2.2 YJIT
![Response-times for: ruby-3.2.2 YJIT](/data/rodauth/plots/rodauth_1_ruby-3.2.2%20YJIT.png "Response-times for: ruby-3.2.2 YJIT")

## Response-times for: ruby-3.3.0
![Response-times for: ruby-3.3.0](/data/rodauth/plots/rodauth_1_ruby-3.3.0.png "Response-times for: ruby-3.3.0")

## Response-times for: ruby-3.3.0 RJIT
![Response-times for: ruby-3.3.0 RJIT](/data/rodauth/plots/rodauth_1_ruby-3.3.0%20RJIT.png "Response-times for: ruby-3.3.0 RJIT")

## Response-times for: ruby-3.3.0 YJIT
![Response-times for: ruby-3.3.0 YJIT](/data/rodauth/plots/rodauth_1_ruby-3.3.0%20YJIT.png "Response-times for: ruby-3.3.0 YJIT")

## Response-times for: ruby-3.3.1
![Response-times for: ruby-3.3.1](/data/rodauth/plots/rodauth_1_ruby-3.3.1.png "Response-times for: ruby-3.3.1")

## Response-times for: ruby-3.3.1 RJIT
![Response-times for: ruby-3.3.1 RJIT](/data/rodauth/plots/rodauth_1_ruby-3.3.1%20RJIT.png "Response-times for: ruby-3.3.1 RJIT")

## Response-times for: ruby-3.3.1 YJIT
![Response-times for: ruby-3.3.1 YJIT](/data/rodauth/plots/rodauth_1_ruby-3.3.1%20YJIT.png "Response-times for: ruby-3.3.1 YJIT")


## Detailed scatter-plots
Same as above but focussing on the most ocurring response times. GC runs are not shown.
## Detailed response-times for: ruby-3.0.4
![Detailed response-times for: ruby-3.0.4](/data/rodauth/plots/rodauth_2_ruby-3.0.4.png "Detailed response-times for: ruby-3.0.4")

## Detailed response-times for: ruby-3.1.3
![Detailed response-times for: ruby-3.1.3](/data/rodauth/plots/rodauth_2_ruby-3.1.3.png "Detailed response-times for: ruby-3.1.3")

## Detailed response-times for: ruby-3.1.3 YJIT
![Detailed response-times for: ruby-3.1.3 YJIT](/data/rodauth/plots/rodauth_2_ruby-3.1.3%20YJIT.png "Detailed response-times for: ruby-3.1.3 YJIT")

## Detailed response-times for: ruby-3.2.2
![Detailed response-times for: ruby-3.2.2](/data/rodauth/plots/rodauth_2_ruby-3.2.2.png "Detailed response-times for: ruby-3.2.2")

## Detailed response-times for: ruby-3.2.2 MJIT
![Detailed response-times for: ruby-3.2.2 MJIT](/data/rodauth/plots/rodauth_2_ruby-3.2.2%20MJIT.png "Detailed response-times for: ruby-3.2.2 MJIT")

## Detailed response-times for: ruby-3.2.2 YJIT
![Detailed response-times for: ruby-3.2.2 YJIT](/data/rodauth/plots/rodauth_2_ruby-3.2.2%20YJIT.png "Detailed response-times for: ruby-3.2.2 YJIT")

## Detailed response-times for: ruby-3.3.0
![Detailed response-times for: ruby-3.3.0](/data/rodauth/plots/rodauth_2_ruby-3.3.0.png "Detailed response-times for: ruby-3.3.0")

## Detailed response-times for: ruby-3.3.0 RJIT
![Detailed response-times for: ruby-3.3.0 RJIT](/data/rodauth/plots/rodauth_2_ruby-3.3.0%20RJIT.png "Detailed response-times for: ruby-3.3.0 RJIT")

## Detailed response-times for: ruby-3.3.0 YJIT
![Detailed response-times for: ruby-3.3.0 YJIT](/data/rodauth/plots/rodauth_2_ruby-3.3.0%20YJIT.png "Detailed response-times for: ruby-3.3.0 YJIT")

## Detailed response-times for: ruby-3.3.1
![Detailed response-times for: ruby-3.3.1](/data/rodauth/plots/rodauth_2_ruby-3.3.1.png "Detailed response-times for: ruby-3.3.1")

## Detailed response-times for: ruby-3.3.1 RJIT
![Detailed response-times for: ruby-3.3.1 RJIT](/data/rodauth/plots/rodauth_2_ruby-3.3.1%20RJIT.png "Detailed response-times for: ruby-3.3.1 RJIT")

## Detailed response-times for: ruby-3.3.1 YJIT
![Detailed response-times for: ruby-3.3.1 YJIT](/data/rodauth/plots/rodauth_2_ruby-3.3.1%20YJIT.png "Detailed response-times for: ruby-3.3.1 YJIT")

