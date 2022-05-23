# Analysis app 'search'
This is a Ruby application that supports a search-as-you-type feature.
It implements an rpc server using the gRPC gem, next it parses the search
string using the parslet gem (regular expressions, creating and accessing
hashes). The results of the parser are looked up in an in-memory GIN index
(all ruby, lots of string manipulation and hash access).
And finally a carthesian product sorted by relevance of all search results
is returned (more hash creation, sorting and converting to json).
The gin index is created once when the application is started by reading a
fixed set of words from a database.

For the test gRPC is configured to use a single thread (pool size = 1).

There are 5 different queries passed to the server:

1. Type 1 simple search (black)
2. Type 1 difficult search (red)
3. Type 1 medium difficult search (green)
4. Type 2 medium difficult search (blue)
5. Type 2 medium difficult search (cyan)

## System
OS: Linux 4.15.0-177-generic #186-Ubuntu SMP Thu Apr 14 20:23:07 UTC 2022 x86_64 GNU/Linux  
CPU: AuthenticAMD AMD Ryzen 7 2700X Eight-Core Processor  

## Tested Rubies
| Ruby                      | JIT  | Mem start |   Mem end |   Runtime |      Mean |    Median |   Std.Dev |     Slow |   Errors |        N |  GC runs |
| ------------------------- | ---- | --------: | --------: | --------: | --------: | --------: | --------: |--------: | -------: | -------: | -------: |
| ruby-2.7.6                |      |      61Mb |      73Mb |      537s |    2.12ms |    1.67ms |    1.23ms |   185270 |        0 |   750000 |        0 |
| ruby-3.0.4                |      |      61Mb |      74Mb |      527s |    2.08ms |    1.68ms |    1.27ms |   178976 |        0 |   750000 |        0 |
| ruby-3.0.4                | MJIT |      62Mb |     134Mb |      470s |    1.84ms |    1.53ms |    1.16ms |    80294 |        0 |   750000 |        0 |
| ruby-3.1.2                |      |      60Mb |      74Mb |      563s |    2.21ms |    1.75ms |    1.45ms |   191315 |        0 |   750000 |        0 |
| ruby-3.1.2                | MJIT |      61Mb |      82Mb |      497s |    1.92ms |    1.53ms |    1.36ms |   158712 |        0 |   750000 |        0 |
| ruby-3.1.2                | YJIT |      75Mb |      89Mb |      456s |     1.8ms |    1.43ms |    1.24ms |    71806 |        0 |   750000 |        0 |

## Winners

- Ruby with lowest __slow__ response-count: __ruby-3.1.2 YJIT__
- Ruby with lowest __median__* response-time: __ruby-3.1.2 YJIT__
- Ruby with lowest __standard deviation__ response-time: __ruby-3.0.4 MJIT__
- Ruby with lowest __mean__* response-time: __ruby-3.1.2 YJIT__

\* Mean and median are calculated after warmup (x > N/2).

## Overview of response-times of all tested Rubies
[Boxplot](https://en.wikipedia.org/wiki/Box_plot) showing ~99% of all measurements (sorted by responsetime)
![Overview of response-times of all tested Rubies](/data/search/plots/search_0_overview.png "Overview of response-times of all tested Rubies")

## Response-times ruby-2.7.6
![Response-times ruby-2.7.6](/data/search/plots/search_1_ruby-2.7.6.png "Response-times ruby-2.7.6")

## Response-times ruby-3.0.4
![Response-times ruby-3.0.4](/data/search/plots/search_1_ruby-3.0.4.png "Response-times ruby-3.0.4")

## Response-times ruby-3.0.4 MJIT
![Response-times ruby-3.0.4 MJIT](/data/search/plots/search_1_ruby-3.0.4%20MJIT.png "Response-times ruby-3.0.4 MJIT")

## Response-times ruby-3.1.2
![Response-times ruby-3.1.2](/data/search/plots/search_1_ruby-3.1.2.png "Response-times ruby-3.1.2")

## Response-times ruby-3.1.2 MJIT
![Response-times ruby-3.1.2 MJIT](/data/search/plots/search_1_ruby-3.1.2%20MJIT.png "Response-times ruby-3.1.2 MJIT")

## Response-times ruby-3.1.2 YJIT
![Response-times ruby-3.1.2 YJIT](/data/search/plots/search_1_ruby-3.1.2%20YJIT.png "Response-times ruby-3.1.2 YJIT")

## Detailed response-times ruby-2.7.6
![Detailed response-times ruby-2.7.6](/data/search/plots/search_2_ruby-2.7.6.png "Detailed response-times ruby-2.7.6")

## Detailed response-times ruby-3.0.4
![Detailed response-times ruby-3.0.4](/data/search/plots/search_2_ruby-3.0.4.png "Detailed response-times ruby-3.0.4")

## Detailed response-times ruby-3.0.4 MJIT
![Detailed response-times ruby-3.0.4 MJIT](/data/search/plots/search_2_ruby-3.0.4%20MJIT.png "Detailed response-times ruby-3.0.4 MJIT")

## Detailed response-times ruby-3.1.2
![Detailed response-times ruby-3.1.2](/data/search/plots/search_2_ruby-3.1.2.png "Detailed response-times ruby-3.1.2")

## Detailed response-times ruby-3.1.2 MJIT
![Detailed response-times ruby-3.1.2 MJIT](/data/search/plots/search_2_ruby-3.1.2%20MJIT.png "Detailed response-times ruby-3.1.2 MJIT")

## Detailed response-times ruby-3.1.2 YJIT
![Detailed response-times ruby-3.1.2 YJIT](/data/search/plots/search_2_ruby-3.1.2%20YJIT.png "Detailed response-times ruby-3.1.2 YJIT")

