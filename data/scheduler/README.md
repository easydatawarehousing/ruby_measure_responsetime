# Analysis app 'scheduler'
This is a planning application built in Ruby.
It involves creating a graph consisting of nodes and edges (Ruby classes)
and iterating over these many times using array 'each' method
and recursive method calls.  
It implements an rpc server using the gRPC gem.
For the test gRPC is configured to use a single thread (pool size = 1).
There are 3 queries passed to the server:

1. Simple plan (black)
2. Medium difficult plan (red)
3. Difficult plan (green)

For this application using YJIT seems worthwhile.
Using 3.2.0 YJIT over 3.1.3 YJIT has benefits and drawbacks, the higher
number of garbage collection runs seems to produce more slow responses.

## System
OS: Linux 4.15.0-204-generic #215-Ubuntu SMP Fri Jan 20 18:24:59 UTC 2023 x86_64 GNU/Linux  
CPU: AuthenticAMD AMD Ryzen 7 2700X Eight-Core Processor  

## Tested Rubies
| Ruby                      | JIT  | Mem start |   Mem end |   Runtime |      Mean |    Median |   Std.Dev |     Slow |   Errors |        N |  GC runs |
| ------------------------- | ---- | --------: | --------: | --------: | --------: | --------: | --------: |--------: | -------: | -------: | -------: |
| ruby-3.0.4                |      |      96Mb |     105Mb |      106s |   14.07ms |   12.92ms |   10.42ms |     1616 |        0 |    30000 |       99 |
| ruby-3.0.4                | MJIT |      95Mb |     107Mb |      111s |   14.64ms |   13.26ms |   11.13ms |     2552 |        0 |    30000 |      126 |
| ruby-3.1.3                |      |      79Mb |      86Mb |       99s |   13.15ms |   12.32ms |    8.93ms |      530 |        0 |    30000 |       70 |
| ruby-3.1.3                | MJIT |      79Mb |      96Mb |       93s |   12.16ms |   11.42ms |    8.49ms |      523 |        0 |    30000 |       71 |
| ruby-3.1.3                | YJIT |      95Mb |     105Mb |       80s |    10.6ms |     9.7ms |    7.31ms |      466 |        0 |    30000 |       71 |
| ruby-3.2.0                |      |      73Mb |      78Mb |      101s |   13.38ms |   11.83ms |   10.06ms |     1358 |        0 |    30000 |      264 |
| ruby-3.2.0                | MJIT |      48Mb |     123Mb |       97s |   12.54ms |   11.04ms |   16.19ms |      613 |        0 |    30000 |      127 |
| ruby-3.2.0                | YJIT |      85Mb |      96Mb |       78s |   10.31ms |    8.62ms |    9.33ms |     1154 |        0 |    30000 |      266 |

## Winners

- Ruby with lowest __slow__ response-count (> 25ms): __ruby-3.1.3 YJIT__ (466x)
- Ruby with lowest __median__* response-time: __ruby-3.2.0 YJIT__ (8.62ms)
- Ruby with lowest __standard deviation__ response-time: __ruby-3.1.3 YJIT__ (7.31ms)
- Ruby with lowest __mean__* response-time: __ruby-3.2.0 YJIT__ (10.31ms)
- Ruby with lowest __memory__ use: __ruby-3.2.0__ (78Mb)

\* Mean and median are calculated after warmup (x > N/2).

## Overview of response-times of all tested Rubies
[Boxplot](https://en.wikipedia.org/wiki/Box_plot) showing ~99% of all measurements (sorted by responsetime)
![Overview of response-times of all tested Rubies](/data/scheduler/plots/scheduler_0_overview.png "Overview of response-times of all tested Rubies")

## Response-times ruby-3.0.4
![Response-times ruby-3.0.4](/data/scheduler/plots/scheduler_1_ruby-3.0.4.png "Response-times ruby-3.0.4")

## Response-times ruby-3.0.4 MJIT
![Response-times ruby-3.0.4 MJIT](/data/scheduler/plots/scheduler_1_ruby-3.0.4%20MJIT.png "Response-times ruby-3.0.4 MJIT")

## Response-times ruby-3.1.3
![Response-times ruby-3.1.3](/data/scheduler/plots/scheduler_1_ruby-3.1.3.png "Response-times ruby-3.1.3")

## Response-times ruby-3.1.3 MJIT
![Response-times ruby-3.1.3 MJIT](/data/scheduler/plots/scheduler_1_ruby-3.1.3%20MJIT.png "Response-times ruby-3.1.3 MJIT")

## Response-times ruby-3.1.3 YJIT
![Response-times ruby-3.1.3 YJIT](/data/scheduler/plots/scheduler_1_ruby-3.1.3%20YJIT.png "Response-times ruby-3.1.3 YJIT")

## Response-times ruby-3.2.0
![Response-times ruby-3.2.0](/data/scheduler/plots/scheduler_1_ruby-3.2.0.png "Response-times ruby-3.2.0")

## Response-times ruby-3.2.0 MJIT
![Response-times ruby-3.2.0 MJIT](/data/scheduler/plots/scheduler_1_ruby-3.2.0%20MJIT.png "Response-times ruby-3.2.0 MJIT")

## Response-times ruby-3.2.0 YJIT
![Response-times ruby-3.2.0 YJIT](/data/scheduler/plots/scheduler_1_ruby-3.2.0%20YJIT.png "Response-times ruby-3.2.0 YJIT")

## Detailed response-times ruby-3.0.4
![Detailed response-times ruby-3.0.4](/data/scheduler/plots/scheduler_2_ruby-3.0.4.png "Detailed response-times ruby-3.0.4")

## Detailed response-times ruby-3.0.4 MJIT
![Detailed response-times ruby-3.0.4 MJIT](/data/scheduler/plots/scheduler_2_ruby-3.0.4%20MJIT.png "Detailed response-times ruby-3.0.4 MJIT")

## Detailed response-times ruby-3.1.3
![Detailed response-times ruby-3.1.3](/data/scheduler/plots/scheduler_2_ruby-3.1.3.png "Detailed response-times ruby-3.1.3")

## Detailed response-times ruby-3.1.3 MJIT
![Detailed response-times ruby-3.1.3 MJIT](/data/scheduler/plots/scheduler_2_ruby-3.1.3%20MJIT.png "Detailed response-times ruby-3.1.3 MJIT")

## Detailed response-times ruby-3.1.3 YJIT
![Detailed response-times ruby-3.1.3 YJIT](/data/scheduler/plots/scheduler_2_ruby-3.1.3%20YJIT.png "Detailed response-times ruby-3.1.3 YJIT")

## Detailed response-times ruby-3.2.0
![Detailed response-times ruby-3.2.0](/data/scheduler/plots/scheduler_2_ruby-3.2.0.png "Detailed response-times ruby-3.2.0")

## Detailed response-times ruby-3.2.0 MJIT
![Detailed response-times ruby-3.2.0 MJIT](/data/scheduler/plots/scheduler_2_ruby-3.2.0%20MJIT.png "Detailed response-times ruby-3.2.0 MJIT")

## Detailed response-times ruby-3.2.0 YJIT
![Detailed response-times ruby-3.2.0 YJIT](/data/scheduler/plots/scheduler_2_ruby-3.2.0%20YJIT.png "Detailed response-times ruby-3.2.0 YJIT")

