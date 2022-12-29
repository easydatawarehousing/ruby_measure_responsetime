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
OS: Linux 4.15.0-200-generic #211-Ubuntu SMP Thu Nov 24 18:16:04 UTC 2022 x86_64 GNU/Linux  
CPU: AuthenticAMD AMD Ryzen 7 2700X Eight-Core Processor  

## Tested Rubies
| Ruby                      | JIT  | Mem start |   Mem end |   Runtime |      Mean |    Median |   Std.Dev |     Slow |   Errors |        N |  GC runs |
| ------------------------- | ---- | --------: | --------: | --------: | --------: | --------: | --------: |--------: | -------: | -------: | -------: |
| ruby-2.0.0-p648           |      |      37Mb |      51Mb |      459s |    1.75ms |    1.13ms |    2.52ms |    46000 |        0 |   750000 |    15325 |
| ruby-2.1.10               |      |      40Mb |      60Mb |      321s |    1.25ms |    1.15ms |     0.4ms |      383 |        0 |   750000 |      119 |
| ruby-2.2.10               |      |      34Mb |      52Mb |      239s |    0.93ms |     0.9ms |    0.32ms |       21 |        0 |   750000 |        4 |
| ruby-2.3.8                |      |      37Mb |      53Mb |      330s |    1.28ms |    1.21ms |    0.29ms |       26 |        0 |   750000 |        5 |
| ruby-2.4.10               |      |      30Mb |      37Mb |      252s |    0.98ms |    0.94ms |    0.26ms |       16 |        0 |   750000 |      267 |
| ruby-2.5.9                |      |      31Mb |      44Mb |      249s |    0.96ms |    0.93ms |    0.28ms |       29 |        0 |   750000 |       11 |
| ruby-2.6.10               |      |      34Mb |      45Mb |      244s |    0.95ms |    0.86ms |    0.54ms |      676 |        0 |   750000 |        7 |
| ruby-2.7.6                |      |      34Mb |      46Mb |      253s |    0.98ms |    0.95ms |    0.28ms |       27 |        0 |   750000 |       75 |
| ruby-3.0.4                |      |      35Mb |      46Mb |      255s |    0.99ms |    0.95ms |    0.35ms |      332 |        0 |   750000 |       43 |
| ruby-3.0.4                | MJIT |      35Mb |      90Mb |      262s |    1.01ms |    0.97ms |    0.36ms |      404 |        0 |   750000 |       47 |
| ruby-3.1.2                |      |      36Mb |      42Mb |      269s |    1.04ms |    0.94ms |    0.73ms |     4914 |        0 |   750000 |      677 |
| ruby-3.1.2                | MJIT |      36Mb |      52Mb |      272s |    1.04ms |    0.94ms |    0.73ms |     5030 |        0 |   750000 |      673 |
| ruby-3.1.2                | YJIT |      47Mb |      56Mb |      284s |     1.1ms |    0.95ms |    1.04ms |     7034 |        0 |   750000 |     1103 |
| ruby-3.2.0                |      |      36Mb |      51Mb |      229s |     0.9ms |    0.83ms |    0.24ms |       13 |        0 |   750000 |        4 |
| ruby-3.2.0                | MJIT |      37Mb |      99Mb |      232s |    0.89ms |    0.83ms |    2.39ms |       43 |        0 |   750000 |        5 |
| ruby-3.2.0                | YJIT |      39Mb |      60Mb |      211s |    0.82ms |    0.76ms |    0.26ms |       24 |        0 |   750000 |        4 |

## Winners

- Ruby with lowest __slow__ response-count: __ruby-3.2.0__
- Ruby with lowest __median__* response-time: __ruby-3.2.0 YJIT__
- Ruby with lowest __standard deviation__ response-time: __ruby-3.2.0__
- Ruby with lowest __mean__* response-time: __ruby-3.2.0 YJIT__

\* Mean and median are calculated after warmup (x > N/2).

## Overview of response-times of all tested Rubies
[Boxplot](https://en.wikipedia.org/wiki/Box_plot) showing ~99% of all measurements (sorted by responsetime)
![Overview of response-times of all tested Rubies](/data/rodauth_mri/plots/rodauth_0_overview.png "Overview of response-times of all tested Rubies")

## Response-times ruby-2.0.0-p648
![Response-times ruby-2.0.0-p648](/data/rodauth_mri/plots/rodauth_1_ruby-2.0.0.png "Response-times ruby-2.0.0-p648")

## Response-times ruby-2.1.10
![Response-times ruby-2.1.10](/data/rodauth_mri/plots/rodauth_1_ruby-2.1.10.png "Response-times ruby-2.1.10")

## Response-times ruby-2.2.10
![Response-times ruby-2.2.10](/data/rodauth_mri/plots/rodauth_1_ruby-2.2.10.png "Response-times ruby-2.2.10")

## Response-times ruby-2.3.8
![Response-times ruby-2.3.8](/data/rodauth_mri/plots/rodauth_1_ruby-2.3.8.png "Response-times ruby-2.3.8")

## Response-times ruby-2.4.10
![Response-times ruby-2.4.10](/data/rodauth_mri/plots/rodauth_1_ruby-2.4.10.png "Response-times ruby-2.4.10")

## Response-times ruby-2.5.9
![Response-times ruby-2.5.9](/data/rodauth_mri/plots/rodauth_1_ruby-2.5.9.png "Response-times ruby-2.5.9")

## Response-times ruby-2.6.10
![Response-times ruby-2.6.10](/data/rodauth_mri/plots/rodauth_1_ruby-2.6.10.png "Response-times ruby-2.6.10")

## Response-times ruby-2.7.6
![Response-times ruby-2.7.6](/data/rodauth_mri/plots/rodauth_1_ruby-2.7.6.png "Response-times ruby-2.7.6")

## Response-times ruby-3.0.4
![Response-times ruby-3.0.4](/data/rodauth_mri/plots/rodauth_1_ruby-3.0.4.png "Response-times ruby-3.0.4")

## Response-times ruby-3.0.4 MJIT
![Response-times ruby-3.0.4 MJIT](/data/rodauth_mri/plots/rodauth_1_ruby-3.0.4%20MJIT.png "Response-times ruby-3.0.4 MJIT")

## Response-times ruby-3.1.2
![Response-times ruby-3.1.2](/data/rodauth_mri/plots/rodauth_1_ruby-3.1.2.png "Response-times ruby-3.1.2")

## Response-times ruby-3.1.2 MJIT
![Response-times ruby-3.1.2 MJIT](/data/rodauth_mri/plots/rodauth_1_ruby-3.1.2%20MJIT.png "Response-times ruby-3.1.2 MJIT")

## Response-times ruby-3.1.2 YJIT
![Response-times ruby-3.1.2 YJIT](/data/rodauth_mri/plots/rodauth_1_ruby-3.1.2%20YJIT.png "Response-times ruby-3.1.2 YJIT")

## Response-times ruby-3.2.0
![Response-times ruby-3.2.0](/data/rodauth_mri/plots/rodauth_1_ruby-3.2.0.png "Response-times ruby-3.2.0")

## Response-times ruby-3.2.0 MJIT
![Response-times ruby-3.2.0 MJIT](/data/rodauth_mri/plots/rodauth_1_ruby-3.2.0%20MJIT.png "Response-times ruby-3.2.0 MJIT")

## Response-times ruby-3.2.0 YJIT
![Response-times ruby-3.2.0 YJIT](/data/rodauth_mri/plots/rodauth_1_ruby-3.2.0%20YJIT.png "Response-times ruby-3.2.0 YJIT")

## Detailed response-times ruby-2.0.0-p648
![Detailed response-times ruby-2.0.0-p648](/data/rodauth_mri/plots/rodauth_2_ruby-2.0.0.png "Detailed response-times ruby-2.0.0-p648")

## Detailed response-times ruby-2.1.10
![Detailed response-times ruby-2.1.10](/data/rodauth_mri/plots/rodauth_2_ruby-2.1.10.png "Detailed response-times ruby-2.1.10")

## Detailed response-times ruby-2.2.10
![Detailed response-times ruby-2.2.10](/data/rodauth_mri/plots/rodauth_2_ruby-2.2.10.png "Detailed response-times ruby-2.2.10")

## Detailed response-times ruby-2.3.8
![Detailed response-times ruby-2.3.8](/data/rodauth_mri/plots/rodauth_2_ruby-2.3.8.png "Detailed response-times ruby-2.3.8")

## Detailed response-times ruby-2.4.10
![Detailed response-times ruby-2.4.10](/data/rodauth_mri/plots/rodauth_2_ruby-2.4.10.png "Detailed response-times ruby-2.4.10")

## Detailed response-times ruby-2.5.9
![Detailed response-times ruby-2.5.9](/data/rodauth_mri/plots/rodauth_2_ruby-2.5.9.png "Detailed response-times ruby-2.5.9")

## Detailed response-times ruby-2.6.10
![Detailed response-times ruby-2.6.10](/data/rodauth_mri/plots/rodauth_2_ruby-2.6.10.png "Detailed response-times ruby-2.6.10")

## Detailed response-times ruby-2.7.6
![Detailed response-times ruby-2.7.6](/data/rodauth_mri/plots/rodauth_2_ruby-2.7.6.png "Detailed response-times ruby-2.7.6")

## Detailed response-times ruby-3.0.4
![Detailed response-times ruby-3.0.4](/data/rodauth_mri/plots/rodauth_2_ruby-3.0.4.png "Detailed response-times ruby-3.0.4")

## Detailed response-times ruby-3.0.4 MJIT
![Detailed response-times ruby-3.0.4 MJIT](/data/rodauth_mri/plots/rodauth_2_ruby-3.0.4%20MJIT.png "Detailed response-times ruby-3.0.4 MJIT")

## Detailed response-times ruby-3.1.2
![Detailed response-times ruby-3.1.2](/data/rodauth_mri/plots/rodauth_2_ruby-3.1.2.png "Detailed response-times ruby-3.1.2")

## Detailed response-times ruby-3.1.2 MJIT
![Detailed response-times ruby-3.1.2 MJIT](/data/rodauth_mri/plots/rodauth_2_ruby-3.1.2%20MJIT.png "Detailed response-times ruby-3.1.2 MJIT")

## Detailed response-times ruby-3.1.2 YJIT
![Detailed response-times ruby-3.1.2 YJIT](/data/rodauth_mri/plots/rodauth_2_ruby-3.1.2%20YJIT.png "Detailed response-times ruby-3.1.2 YJIT")

## Detailed response-times ruby-3.2.0
![Detailed response-times ruby-3.2.0](/data/rodauth_mri/plots/rodauth_2_ruby-3.2.0.png "Detailed response-times ruby-3.2.0")

## Detailed response-times ruby-3.2.0 MJIT
![Detailed response-times ruby-3.2.0 MJIT](/data/rodauth_mri/plots/rodauth_2_ruby-3.2.0%20MJIT.png "Detailed response-times ruby-3.2.0 MJIT")

## Detailed response-times ruby-3.2.0 YJIT
![Detailed response-times ruby-3.2.0 YJIT](/data/rodauth_mri/plots/rodauth_2_ruby-3.2.0%20YJIT.png "Detailed response-times ruby-3.2.0 YJIT")

