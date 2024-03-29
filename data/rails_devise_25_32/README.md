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
OS: Linux 4.15.0-204-generic #215-Ubuntu SMP Fri Jan 20 18:24:59 UTC 2023 x86_64 GNU/Linux  
CPU: AuthenticAMD AMD Ryzen 7 2700X Eight-Core Processor  

## Tested Rubies
| Ruby                      | JIT  | Mem start |   Mem end |   Runtime |      Mean |    Median |   Std.Dev |     Slow |   Errors |        N |  GC runs |
| ------------------------- | ---- | --------: | --------: | --------: | --------: | --------: | --------: |--------: | -------: | -------: | -------: |
| ruby-2.5.9                |      |      60Mb |     117Mb |     1175s |    4.64ms |    4.79ms |    1.31ms |     5708 |        0 |   750000 |       55 |
| ruby-2.6.10               |      |      66Mb |     118Mb |     1047s |    4.13ms |    4.06ms |    1.79ms |    40685 |        0 |   750000 |       49 |
| ruby-2.7.6                |      |      64Mb |     113Mb |     1116s |     4.4ms |    4.51ms |    1.32ms |     5129 |        0 |   750000 |       49 |
| ruby-3.0.4                |      |      64Mb |     102Mb |     1230s |    4.89ms |    4.87ms |    1.99ms |    32397 |        0 |   750000 |      412 |
| ruby-3.0.4                | MJIT |      62Mb |     158Mb |     1315s |    5.31ms |    5.02ms |    3.02ms |    45018 |        0 |   750000 |     1368 |
| ruby-3.1.2                |      |      67Mb |      98Mb |     1180s |    4.67ms |    4.69ms |    2.08ms |    14242 |        0 |   750000 |      545 |
| ruby-3.1.2                | MJIT |      64Mb |     146Mb |     1321s |    5.05ms |    4.75ms |    3.62ms |    43959 |        0 |   750000 |     2131 |
| ruby-3.1.2                | YJIT |      77Mb |     132Mb |     1361s |    5.38ms |    5.44ms |    1.98ms |    41548 |        0 |   750000 |      226 |
| ruby-3.2.0                |      |      69Mb |     104Mb |     1001s |    3.94ms |    3.99ms |    0.97ms |     2372 |        0 |   750000 |       79 |
| ruby-3.2.0                | MJIT |      70Mb |     176Mb |     1017s |    4.02ms |    4.09ms |    1.44ms |     1688 |        0 |   750000 |       16 |
| ruby-3.2.0                | YJIT |      73Mb |     133Mb |      756s |    2.99ms |    2.95ms |    0.86ms |      878 |        0 |   750000 |       65 |
| truffleruby-22.0.0.2      |      |           |    3319Mb |     1812s |    5.73ms |    4.59ms |   33.92ms |    96883 |        0 |   750000 |      121 |

## Winners

- Ruby with lowest __slow__ response-count (> 7ms): __ruby-3.2.0 YJIT__ (878x)
- Ruby with lowest __median__* response-time: __ruby-3.2.0 YJIT__ (2.95ms)
- Ruby with lowest __standard deviation__ response-time: __ruby-3.2.0 YJIT__ (0.86ms)
- Ruby with lowest __mean__* response-time: __ruby-3.2.0 YJIT__ (2.99ms)
- Ruby with lowest __memory__ use: __ruby-3.1.2__ (98Mb)

\* Mean and median are calculated after warmup (x > N/2).

## Overview of response-times of all tested Rubies
[Boxplot](https://en.wikipedia.org/wiki/Box_plot) showing ~99% of all measurements (sorted by responsetime)
![Overview of response-times of all tested Rubies](/data/rails_devise_25_32/plots/rails_devise_0_overview.png "Overview of response-times of all tested Rubies")

## Response-times ruby-2.5.9
![Response-times ruby-2.5.9](/data/rails_devise_25_32/plots/rails_devise_1_ruby-2.5.9.png "Response-times ruby-2.5.9")

## Response-times ruby-2.6.10
![Response-times ruby-2.6.10](/data/rails_devise_25_32/plots/rails_devise_1_ruby-2.6.10.png "Response-times ruby-2.6.10")

## Response-times ruby-2.7.6
![Response-times ruby-2.7.6](/data/rails_devise_25_32/plots/rails_devise_1_ruby-2.7.6.png "Response-times ruby-2.7.6")

## Response-times ruby-3.0.4
![Response-times ruby-3.0.4](/data/rails_devise_25_32/plots/rails_devise_1_ruby-3.0.4.png "Response-times ruby-3.0.4")

## Response-times ruby-3.0.4 MJIT
![Response-times ruby-3.0.4 MJIT](/data/rails_devise_25_32/plots/rails_devise_1_ruby-3.0.4%20MJIT.png "Response-times ruby-3.0.4 MJIT")

## Response-times ruby-3.1.2
![Response-times ruby-3.1.2](/data/rails_devise_25_32/plots/rails_devise_1_ruby-3.1.2.png "Response-times ruby-3.1.2")

## Response-times ruby-3.1.2 MJIT
![Response-times ruby-3.1.2 MJIT](/data/rails_devise_25_32/plots/rails_devise_1_ruby-3.1.2%20MJIT.png "Response-times ruby-3.1.2 MJIT")

## Response-times ruby-3.1.2 YJIT
![Response-times ruby-3.1.2 YJIT](/data/rails_devise_25_32/plots/rails_devise_1_ruby-3.1.2%20YJIT.png "Response-times ruby-3.1.2 YJIT")

## Response-times ruby-3.2.0
![Response-times ruby-3.2.0](/data/rails_devise_25_32/plots/rails_devise_1_ruby-3.2.0.png "Response-times ruby-3.2.0")

## Response-times ruby-3.2.0 MJIT
![Response-times ruby-3.2.0 MJIT](/data/rails_devise_25_32/plots/rails_devise_1_ruby-3.2.0%20MJIT.png "Response-times ruby-3.2.0 MJIT")

## Response-times ruby-3.2.0 YJIT
![Response-times ruby-3.2.0 YJIT](/data/rails_devise_25_32/plots/rails_devise_1_ruby-3.2.0%20YJIT.png "Response-times ruby-3.2.0 YJIT")

## Response-times truffleruby-22.0.0.2
![Response-times truffleruby-22.0.0.2](/data/rails_devise_25_32/plots/rails_devise_1_truffleruby-22.0.0.2.png "Response-times truffleruby-22.0.0.2")

## Detailed response-times ruby-2.5.9
![Detailed response-times ruby-2.5.9](/data/rails_devise_25_32/plots/rails_devise_2_ruby-2.5.9.png "Detailed response-times ruby-2.5.9")

## Detailed response-times ruby-2.6.10
![Detailed response-times ruby-2.6.10](/data/rails_devise_25_32/plots/rails_devise_2_ruby-2.6.10.png "Detailed response-times ruby-2.6.10")

## Detailed response-times ruby-2.7.6
![Detailed response-times ruby-2.7.6](/data/rails_devise_25_32/plots/rails_devise_2_ruby-2.7.6.png "Detailed response-times ruby-2.7.6")

## Detailed response-times ruby-3.0.4
![Detailed response-times ruby-3.0.4](/data/rails_devise_25_32/plots/rails_devise_2_ruby-3.0.4.png "Detailed response-times ruby-3.0.4")

## Detailed response-times ruby-3.0.4 MJIT
![Detailed response-times ruby-3.0.4 MJIT](/data/rails_devise_25_32/plots/rails_devise_2_ruby-3.0.4%20MJIT.png "Detailed response-times ruby-3.0.4 MJIT")

## Detailed response-times ruby-3.1.2
![Detailed response-times ruby-3.1.2](/data/rails_devise_25_32/plots/rails_devise_2_ruby-3.1.2.png "Detailed response-times ruby-3.1.2")

## Detailed response-times ruby-3.1.2 MJIT
![Detailed response-times ruby-3.1.2 MJIT](/data/rails_devise_25_32/plots/rails_devise_2_ruby-3.1.2%20MJIT.png "Detailed response-times ruby-3.1.2 MJIT")

## Detailed response-times ruby-3.1.2 YJIT
![Detailed response-times ruby-3.1.2 YJIT](/data/rails_devise_25_32/plots/rails_devise_2_ruby-3.1.2%20YJIT.png "Detailed response-times ruby-3.1.2 YJIT")

## Detailed response-times ruby-3.2.0
![Detailed response-times ruby-3.2.0](/data/rails_devise_25_32/plots/rails_devise_2_ruby-3.2.0.png "Detailed response-times ruby-3.2.0")

## Detailed response-times ruby-3.2.0 MJIT
![Detailed response-times ruby-3.2.0 MJIT](/data/rails_devise_25_32/plots/rails_devise_2_ruby-3.2.0%20MJIT.png "Detailed response-times ruby-3.2.0 MJIT")

## Detailed response-times ruby-3.2.0 YJIT
![Detailed response-times ruby-3.2.0 YJIT](/data/rails_devise_25_32/plots/rails_devise_2_ruby-3.2.0%20YJIT.png "Detailed response-times ruby-3.2.0 YJIT")

## Detailed response-times truffleruby-22.0.0.2
![Detailed response-times truffleruby-22.0.0.2](/data/rails_devise_25_32/plots/rails_devise_2_truffleruby-22.0.0.2.png "Detailed response-times truffleruby-22.0.0.2")

