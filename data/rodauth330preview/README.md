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
OS: Linux 4.15.0-210-generic #221-Ubuntu SMP Tue Apr 18 08:32:52 UTC 2023 x86_64 GNU/Linux  
CPU: AuthenticAMD AMD Ryzen 7 2700X Eight-Core Processor  

## Tested Rubies
| Ruby                      | JIT  | Mem start |   Mem end |   Runtime |      Mean |    Median |   Std.Dev |     Slow |   Errors |        N |  GC runs |
| ------------------------- | ---- | --------: | --------: | --------: | --------: | --------: | --------: |--------: | -------: | -------: | -------: |
| ruby-2.7.6                |      |      36Mb |      44Mb |       50s |    0.97ms |    0.92ms |    0.29ms |        6 |        0 |   150000 |       10 |
| ruby-3.0.4                |      |      34Mb |      40Mb |       50s |    0.96ms |    0.92ms |    0.39ms |      170 |        0 |   150000 |       22 |
| ruby-3.0.4                | MJIT |      34Mb |      47Mb |       50s |    0.94ms |    0.89ms |     0.4ms |      171 |        0 |   150000 |       22 |
| ruby-3.1.3                |      |      36Mb |      42Mb |       49s |    0.98ms |    0.94ms |    0.44ms |      242 |        0 |   150000 |       30 |
| ruby-3.1.3                | MJIT |      36Mb |      49Mb |       53s |    1.03ms |    0.97ms |    0.45ms |      248 |        0 |   150000 |       30 |
| ruby-3.1.3                | YJIT |      46Mb |      56Mb |       49s |    0.94ms |    0.88ms |    0.54ms |      468 |        0 |   150000 |       52 |
| ruby-3.2.2                |      |      35Mb |      50Mb |       48s |    0.93ms |    0.87ms |    0.31ms |        7 |        0 |   150000 |        1 |
| ruby-3.2.2                | MJIT |      36Mb |      74Mb |       49s |    0.93ms |    0.88ms |    3.97ms |       33 |        0 |   150000 |        3 |
| ruby-3.2.2                | YJIT |      36Mb |      56Mb |       43s |    0.85ms |     0.8ms |    0.44ms |       11 |        0 |   150000 |        1 |
| ruby-3.3.0-preview1       |      |      37Mb |      47Mb |       47s |     0.9ms |    0.85ms |    0.31ms |       12 |        0 |   150000 |        2 |
| ruby-3.3.0-preview1       | RJIT |      89Mb |     253Mb |       55s |    0.93ms |    0.79ms |   12.09ms |     1547 |        0 |   150000 |        2 |
| ruby-3.3.0-preview1       | YJIT |      39Mb |      54Mb |       43s |    0.82ms |    0.78ms |    0.52ms |       24 |        0 |   150000 |        2 |

## Winners

- Ruby with lowest __slow__ response-count (> 5ms): __ruby-2.7.6__ (6x)
- Ruby with lowest __median__* response-time: __ruby-3.3.0-preview1 YJIT__ (0.78ms)
- Ruby with lowest __standard deviation__ response-time: __ruby-2.7.6__ (0.29ms)
- Ruby with lowest __mean__* response-time: __ruby-3.3.0-preview1 YJIT__ (0.82ms)
- Ruby with lowest __memory__ use: __ruby-3.0.4__ (40Mb)

\* Mean and median are calculated after warmup (x > N/2).

## Overview of response-times of all tested Rubies
[Boxplot](https://en.wikipedia.org/wiki/Box_plot) showing ~99% of all measurements (sorted by responsetime)
![Overview of response-times of all tested Rubies](/data/rodauth330preview/plots/rodauth_0_overview.png "Overview of response-times of all tested Rubies")

## Histograms of response-times of all tested Rubies
Showing a single tested uri and the most occurring response-times
![Histograms of response-times of all tested Rubies](/data/rodauth330preview/plots/rodauth_01_histogram.png "Histograms of response-times of all tested Rubies")

## Scatter-plots
These scatter-plots show the response time of individual calls as dots. Note that many dots may overlap each other.  
Vertical blue lines near the X-axis indicate major garbage collection runs (of Run-ID 1).
## Response-times for: ruby-2.7.6
![Response-times for: ruby-2.7.6](/data/rodauth330preview/plots/rodauth_1_ruby-2.7.6.png "Response-times for: ruby-2.7.6")

## Response-times for: ruby-3.0.4
![Response-times for: ruby-3.0.4](/data/rodauth330preview/plots/rodauth_1_ruby-3.0.4.png "Response-times for: ruby-3.0.4")

## Response-times for: ruby-3.0.4 MJIT
![Response-times for: ruby-3.0.4 MJIT](/data/rodauth330preview/plots/rodauth_1_ruby-3.0.4%20MJIT.png "Response-times for: ruby-3.0.4 MJIT")

## Response-times for: ruby-3.1.3
![Response-times for: ruby-3.1.3](/data/rodauth330preview/plots/rodauth_1_ruby-3.1.3.png "Response-times for: ruby-3.1.3")

## Response-times for: ruby-3.1.3 MJIT
![Response-times for: ruby-3.1.3 MJIT](/data/rodauth330preview/plots/rodauth_1_ruby-3.1.3%20MJIT.png "Response-times for: ruby-3.1.3 MJIT")

## Response-times for: ruby-3.1.3 YJIT
![Response-times for: ruby-3.1.3 YJIT](/data/rodauth330preview/plots/rodauth_1_ruby-3.1.3%20YJIT.png "Response-times for: ruby-3.1.3 YJIT")

## Response-times for: ruby-3.2.2
![Response-times for: ruby-3.2.2](/data/rodauth330preview/plots/rodauth_1_ruby-3.2.2.png "Response-times for: ruby-3.2.2")

## Response-times for: ruby-3.2.2 MJIT
![Response-times for: ruby-3.2.2 MJIT](/data/rodauth330preview/plots/rodauth_1_ruby-3.2.2%20MJIT.png "Response-times for: ruby-3.2.2 MJIT")

## Response-times for: ruby-3.2.2 YJIT
![Response-times for: ruby-3.2.2 YJIT](/data/rodauth330preview/plots/rodauth_1_ruby-3.2.2%20YJIT.png "Response-times for: ruby-3.2.2 YJIT")

## Response-times for: ruby-3.3.0-preview1
![Response-times for: ruby-3.3.0-preview1](/data/rodauth330preview/plots/rodauth_1_ruby-3.3.0.png "Response-times for: ruby-3.3.0-preview1")

## Response-times for: ruby-3.3.0-preview1 RJIT
![Response-times for: ruby-3.3.0-preview1 RJIT](/data/rodauth330preview/plots/rodauth_1_ruby-3.3.0%20RJIT.png "Response-times for: ruby-3.3.0-preview1 RJIT")

## Response-times for: ruby-3.3.0-preview1 YJIT
![Response-times for: ruby-3.3.0-preview1 YJIT](/data/rodauth330preview/plots/rodauth_1_ruby-3.3.0%20YJIT.png "Response-times for: ruby-3.3.0-preview1 YJIT")


## Detailed scatter-plots
Same as above but focussing on the most ocurring response times. GC runs are not shown.
## Detailed response-times for: ruby-2.7.6
![Detailed response-times for: ruby-2.7.6](/data/rodauth330preview/plots/rodauth_2_ruby-2.7.6.png "Detailed response-times for: ruby-2.7.6")

## Detailed response-times for: ruby-3.0.4
![Detailed response-times for: ruby-3.0.4](/data/rodauth330preview/plots/rodauth_2_ruby-3.0.4.png "Detailed response-times for: ruby-3.0.4")

## Detailed response-times for: ruby-3.0.4 MJIT
![Detailed response-times for: ruby-3.0.4 MJIT](/data/rodauth330preview/plots/rodauth_2_ruby-3.0.4%20MJIT.png "Detailed response-times for: ruby-3.0.4 MJIT")

## Detailed response-times for: ruby-3.1.3
![Detailed response-times for: ruby-3.1.3](/data/rodauth330preview/plots/rodauth_2_ruby-3.1.3.png "Detailed response-times for: ruby-3.1.3")

## Detailed response-times for: ruby-3.1.3 MJIT
![Detailed response-times for: ruby-3.1.3 MJIT](/data/rodauth330preview/plots/rodauth_2_ruby-3.1.3%20MJIT.png "Detailed response-times for: ruby-3.1.3 MJIT")

## Detailed response-times for: ruby-3.1.3 YJIT
![Detailed response-times for: ruby-3.1.3 YJIT](/data/rodauth330preview/plots/rodauth_2_ruby-3.1.3%20YJIT.png "Detailed response-times for: ruby-3.1.3 YJIT")

## Detailed response-times for: ruby-3.2.2
![Detailed response-times for: ruby-3.2.2](/data/rodauth330preview/plots/rodauth_2_ruby-3.2.2.png "Detailed response-times for: ruby-3.2.2")

## Detailed response-times for: ruby-3.2.2 MJIT
![Detailed response-times for: ruby-3.2.2 MJIT](/data/rodauth330preview/plots/rodauth_2_ruby-3.2.2%20MJIT.png "Detailed response-times for: ruby-3.2.2 MJIT")

## Detailed response-times for: ruby-3.2.2 YJIT
![Detailed response-times for: ruby-3.2.2 YJIT](/data/rodauth330preview/plots/rodauth_2_ruby-3.2.2%20YJIT.png "Detailed response-times for: ruby-3.2.2 YJIT")

## Detailed response-times for: ruby-3.3.0-preview1
![Detailed response-times for: ruby-3.3.0-preview1](/data/rodauth330preview/plots/rodauth_2_ruby-3.3.0.png "Detailed response-times for: ruby-3.3.0-preview1")

## Detailed response-times for: ruby-3.3.0-preview1 RJIT
![Detailed response-times for: ruby-3.3.0-preview1 RJIT](/data/rodauth330preview/plots/rodauth_2_ruby-3.3.0%20RJIT.png "Detailed response-times for: ruby-3.3.0-preview1 RJIT")

## Detailed response-times for: ruby-3.3.0-preview1 YJIT
![Detailed response-times for: ruby-3.3.0-preview1 YJIT](/data/rodauth330preview/plots/rodauth_2_ruby-3.3.0%20YJIT.png "Detailed response-times for: ruby-3.3.0-preview1 YJIT")

