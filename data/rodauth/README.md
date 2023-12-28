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
OS: Linux 5.15.0-91-generic #101-Ubuntu SMP Tue Nov 14 13:30:08 UTC 2023 x86_64 GNU/Linux  
CPU: AuthenticAMD AMD Ryzen 7 5800X 8-Core Processor  

## Tested Rubies
| Ruby                      | JIT  | Mem start |   Mem end |   Runtime |      Mean |    Median |   Std.Dev |     Slow |   Errors |        N |  GC runs |
| ------------------------- | ---- | --------: | --------: | --------: | --------: | --------: | --------: |--------: | -------: | -------: | -------: |
| ruby-3.0.4                |      |      35Mb |      41Mb |      154s |    0.61ms |    0.55ms |    0.51ms |     4422 |        0 |   750000 |     1087 |
| ruby-3.1.3                |      |      37Mb |      43Mb |      157s |    0.62ms |    0.56ms |    0.56ms |     5872 |        0 |   750000 |     1360 |
| ruby-3.1.3                | YJIT |      47Mb |      62Mb |      149s |    0.59ms |    0.57ms |    0.19ms |      221 |        0 |   750000 |       49 |
| ruby-3.2.2                |      |      37Mb |      52Mb |      124s |    0.49ms |    0.46ms |    0.13ms |       23 |        0 |   750000 |       19 |
| ruby-3.2.2                | MJIT |      37Mb |      52Mb |      125s |    0.49ms |    0.46ms |    0.13ms |       30 |        0 |   750000 |       19 |
| ruby-3.2.2                | YJIT |      38Mb |      58Mb |      114s |    0.45ms |    0.43ms |    0.17ms |       55 |        0 |   750000 |       22 |
| ruby-3.3.0                |      |      41Mb |     133Mb |      139s |    0.55ms |    0.53ms |    0.13ms |        3 |        0 |   750000 |        0 |
| ruby-3.3.0                | RJIT |      76Mb |     282Mb |      143s |    0.56ms |    0.49ms |    2.84ms |     5589 |        0 |   750000 |        1 |
| ruby-3.3.0                | YJIT |      42Mb |     140Mb |      119s |    0.47ms |    0.46ms |    0.18ms |       12 |        0 |   750000 |        1 |

## Winners

- Ruby with lowest __slow__ response-count (> 5ms): __ruby-3.3.0__ (3x)
- Ruby with lowest __median__* response-time: __ruby-3.2.2 YJIT__ (0.43ms)
- Ruby with lowest __standard deviation__ response-time: __ruby-3.2.2 MJIT__ (0.13ms)
- Ruby with lowest __mean__* response-time: __ruby-3.2.2 YJIT__ (0.45ms)
- Ruby with lowest __memory__ use: __ruby-3.0.4__ (41Mb)

\* Mean and median are calculated after warmup (x > N/2).

## Overview of response-times of all tested Rubies
[Boxplot](https://en.wikipedia.org/wiki/Box_plot) showing ~99% of all measurements (sorted by responsetime)
![Overview of response-times of all tested Rubies](/data/rodauth/plots/rodauth_0_overview.png "Overview of response-times of all tested Rubies")

## Histograms of response-times of all tested Rubies
Showing a single tested uri and the most occurring response-times after warmup (x > N/2)
![Histograms of response-times of all tested Rubies](/data/rodauth/plots/rodauth_01_histogram.png "Histograms of response-times of all tested Rubies")

## Scatter-plots
These scatter-plots show the response time of individual calls as dots. Note that many dots may overlap each other.  
Vertical blue lines near the X-axis indicate major garbage collection runs (of Run-ID 1, only when there are less than 100 GC runs).
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

