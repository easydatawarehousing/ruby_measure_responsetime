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
OS: Linux 4.15.0-177-generic #186-Ubuntu SMP Thu Apr 14 20:23:07 UTC 2022 x86_64 GNU/Linux  
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
| ruby-3.2.0-preview1       |      |      64Mb |      97Mb |     1068s |    4.22ms |    4.26ms |     1.7ms |     3811 |        0 |   750000 |      183 |
| ruby-3.2.0-preview1       | MJIT |      67Mb |     147Mb |     1198s |    4.51ms |    4.32ms |     3.5ms |    13100 |        0 |   750000 |     1682 |
| ruby-3.2.0-preview1       | YJIT |      77Mb |     119Mb |     1359s |    5.37ms |    5.42ms |    2.59ms |    35053 |        0 |   750000 |      471 |
| truffleruby-22.0.0.2      |      |           |    3319Mb |     1812s |    5.73ms |    4.59ms |   33.92ms |    96883 |        0 |   750000 |      121 |

## Winners

- Ruby with lowest __slow__ response-count: __ruby-3.2.0-preview1__
- Ruby with lowest __median__* response-time: __ruby-2.6.10__
- Ruby with lowest __standard deviation__ response-time: __ruby-2.5.9__
- Ruby with lowest __mean__* response-time: __ruby-2.6.10__

\* Mean and median are calculated after warmup (x > N/2).

## Overview of response-times of all tested Rubies
[Boxplot](https://en.wikipedia.org/wiki/Box_plot) showing ~99% of all measurements (sorted by responsetime)
![Overview of response-times of all tested Rubies](/data/rails_devise/plots/rails_devise_0_overview.png "Overview of response-times of all tested Rubies")

## Response-times ruby-2.5.9
![Response-times ruby-2.5.9](/data/rails_devise/plots/rails_devise_1_ruby-2.5.9.png "Response-times ruby-2.5.9")

## Response-times ruby-2.6.10
![Response-times ruby-2.6.10](/data/rails_devise/plots/rails_devise_1_ruby-2.6.10.png "Response-times ruby-2.6.10")

## Response-times ruby-2.7.6
![Response-times ruby-2.7.6](/data/rails_devise/plots/rails_devise_1_ruby-2.7.6.png "Response-times ruby-2.7.6")

## Response-times ruby-3.0.4
![Response-times ruby-3.0.4](/data/rails_devise/plots/rails_devise_1_ruby-3.0.4.png "Response-times ruby-3.0.4")

## Response-times ruby-3.0.4 MJIT
![Response-times ruby-3.0.4 MJIT](/data/rails_devise/plots/rails_devise_1_ruby-3.0.4%20MJIT.png "Response-times ruby-3.0.4 MJIT")

## Response-times ruby-3.1.2
![Response-times ruby-3.1.2](/data/rails_devise/plots/rails_devise_1_ruby-3.1.2.png "Response-times ruby-3.1.2")

## Response-times ruby-3.1.2 MJIT
![Response-times ruby-3.1.2 MJIT](/data/rails_devise/plots/rails_devise_1_ruby-3.1.2%20MJIT.png "Response-times ruby-3.1.2 MJIT")

## Response-times ruby-3.1.2 YJIT
![Response-times ruby-3.1.2 YJIT](/data/rails_devise/plots/rails_devise_1_ruby-3.1.2%20YJIT.png "Response-times ruby-3.1.2 YJIT")

## Response-times ruby-3.2.0-preview1
![Response-times ruby-3.2.0-preview1](/data/rails_devise/plots/rails_devise_1_ruby-3.2.0.png "Response-times ruby-3.2.0-preview1")

## Response-times ruby-3.2.0-preview1 MJIT
![Response-times ruby-3.2.0-preview1 MJIT](/data/rails_devise/plots/rails_devise_1_ruby-3.2.0%20MJIT.png "Response-times ruby-3.2.0-preview1 MJIT")

## Response-times ruby-3.2.0-preview1 YJIT
![Response-times ruby-3.2.0-preview1 YJIT](/data/rails_devise/plots/rails_devise_1_ruby-3.2.0%20YJIT.png "Response-times ruby-3.2.0-preview1 YJIT")

## Response-times truffleruby-22.0.0.2
![Response-times truffleruby-22.0.0.2](/data/rails_devise/plots/rails_devise_1_truffleruby-22.0.0.2.png "Response-times truffleruby-22.0.0.2")

## Detailed response-times ruby-2.5.9
![Detailed response-times ruby-2.5.9](/data/rails_devise/plots/rails_devise_2_ruby-2.5.9.png "Detailed response-times ruby-2.5.9")

## Detailed response-times ruby-2.6.10
![Detailed response-times ruby-2.6.10](/data/rails_devise/plots/rails_devise_2_ruby-2.6.10.png "Detailed response-times ruby-2.6.10")

## Detailed response-times ruby-2.7.6
![Detailed response-times ruby-2.7.6](/data/rails_devise/plots/rails_devise_2_ruby-2.7.6.png "Detailed response-times ruby-2.7.6")

## Detailed response-times ruby-3.0.4
![Detailed response-times ruby-3.0.4](/data/rails_devise/plots/rails_devise_2_ruby-3.0.4.png "Detailed response-times ruby-3.0.4")

## Detailed response-times ruby-3.0.4 MJIT
![Detailed response-times ruby-3.0.4 MJIT](/data/rails_devise/plots/rails_devise_2_ruby-3.0.4%20MJIT.png "Detailed response-times ruby-3.0.4 MJIT")

## Detailed response-times ruby-3.1.2
![Detailed response-times ruby-3.1.2](/data/rails_devise/plots/rails_devise_2_ruby-3.1.2.png "Detailed response-times ruby-3.1.2")

## Detailed response-times ruby-3.1.2 MJIT
![Detailed response-times ruby-3.1.2 MJIT](/data/rails_devise/plots/rails_devise_2_ruby-3.1.2%20MJIT.png "Detailed response-times ruby-3.1.2 MJIT")

## Detailed response-times ruby-3.1.2 YJIT
![Detailed response-times ruby-3.1.2 YJIT](/data/rails_devise/plots/rails_devise_2_ruby-3.1.2%20YJIT.png "Detailed response-times ruby-3.1.2 YJIT")

## Detailed response-times ruby-3.2.0-preview1
![Detailed response-times ruby-3.2.0-preview1](/data/rails_devise/plots/rails_devise_2_ruby-3.2.0.png "Detailed response-times ruby-3.2.0-preview1")

## Detailed response-times ruby-3.2.0-preview1 MJIT
![Detailed response-times ruby-3.2.0-preview1 MJIT](/data/rails_devise/plots/rails_devise_2_ruby-3.2.0%20MJIT.png "Detailed response-times ruby-3.2.0-preview1 MJIT")

## Detailed response-times ruby-3.2.0-preview1 YJIT
![Detailed response-times ruby-3.2.0-preview1 YJIT](/data/rails_devise/plots/rails_devise_2_ruby-3.2.0%20YJIT.png "Detailed response-times ruby-3.2.0-preview1 YJIT")

## Detailed response-times truffleruby-22.0.0.2
![Detailed response-times truffleruby-22.0.0.2](/data/rails_devise/plots/rails_devise_2_truffleruby-22.0.0.2.png "Detailed response-times truffleruby-22.0.0.2")

