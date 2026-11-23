STOCK MARKET ANALYSIS USING SQL
Insights Report

Analysis Period: January 2015 – July 2018

Student Name: Manjula M.
Project: SQL Stock Market Analysis
Database: MySQL

 
1. Introduction
This report presents the insights obtained from the SQL-based analysis of six NSE stocks: Bajaj Auto, Eicher Motors, Hero Motocorp, Infosys, TCS and TVS Motors. The analysis covers the period from January 2015 to July 2018.
The analysis uses closing prices, 20-day and 50-day moving averages, and moving-average crossover signals to understand price trends and possible Buy and Sell signals. The analysis also investigates unusually large one-day price movements and adjusts the affected price series for bonus issues.
2. Stock Performance and Trading Signals
Stock	Buy Signals	Sell Signals	Adjusted / Full-Period Change	Latest Signal
Bajaj Auto	12	11	+10.0%	Buy
Eicher Motors	6	7	+82.6%	Sell
Hero Motocorp	9	9	+6.0%	Sell
Infosys	9	9	+38.2%	Buy
TCS	12	13	+52.4%	Sell
TVS Motors	8	8	+86.9%	Sell

3. Bajaj Auto
Bajaj Auto generated 12 Buy signals and 11 Sell signals during the analysis period. The latest signal was Buy, indicating that the short-term moving-average trend was positive at the latest identified crossover. The closing price increased from ₹2,454.10 at the beginning of the period to ₹2,700.70 at the end, representing approximately a 10.0% increase. The Buy/Sell signal counts indicate that the crossover strategy produced relatively few trading signals compared with the total number of trading days.
4. Eicher Motors
Eicher Motors generated 6 Buy signals and 7 Sell signals. The latest signal was Sell. The stock increased from ₹15,239.15 to ₹27,820.95 over the full period, giving approximately an 82.6% increase. Therefore, although the latest moving-average signal was negative, the overall long-term price movement was strongly positive.
5. Hero Motocorp
Hero Motocorp generated 9 Buy signals and 9 Sell signals. The latest signal was Sell. The closing price increased from ₹3,107.30 to ₹3,293.80, representing approximately a 6.0% increase. The equal number of Buy and Sell signals indicates that the crossover method identified several changes in direction, while the overall price movement remained moderately positive.
6. Infosys
Infosys generated 9 Buy signals and 9 Sell signals, with the latest signal being Buy. The original price series contained an unusually large downward movement associated with a corporate action. After adjusting the historical prices for the identified 1:1 bonus issue, the full-period return was approximately 38.2%. Therefore, the adjusted series provides a more meaningful comparison of the stock's value across the full analysis period.
7. TCS
TCS generated 12 Buy signals and 13 Sell signals, with the latest signal being Sell. The unadjusted series contained an unusually large one-day decline associated with a corporate action. After adjusting historical prices for the identified 1:1 bonus issue, the full-period return became approximately 52.4%. This demonstrates why corporate actions must be considered before interpreting historical price changes.
8. TVS Motors
TVS Motors generated 8 Buy signals and 8 Sell signals. The latest signal was Sell. The stock increased from ₹276.85 to ₹517.45, representing approximately an 86.9% increase. TVS Motors therefore showed the strongest full-period price increase among the six stocks in the analysis.
9. Data Quality and Corporate Actions
The analysis identified two unusually large one-day price movements that were substantially different from the normal daily movements of the other stocks. The affected stocks were TCS and Infosys.
The two events were treated as 1:1 bonus issues. In a 1:1 bonus issue, the number of shares doubles and the corresponding market price can approximately halve. Therefore, historical prices before the event were divided by 2 so that the price series could be compared consistently across the event date.
After adjustment, the full-period return was 52.4% for TCS and 38.2% for Infosys. This adjustment is important because otherwise a corporate action could incorrectly appear to be a very large loss in the stock's market value.
10. Moving Average and Golden-Cross Method
The analysis uses a 20-day moving average (MA20) and a 50-day moving average (MA50). A Buy signal is generated when the MA20 crosses above the MA50, while a Sell signal is generated when the MA20 crosses below the MA50. All other days are classified as Hold.
The moving averages use historical closing prices. Therefore, a moving-average crossover does not predict the future from information that is not yet available. It reacts to price movements that have already occurred.
The 50-day moving average also responds more slowly than the 20-day moving average. As a result, a golden cross can confirm a developing trend rather than identify its exact beginning.
11. Limitations of the Analysis
The SQL analysis is useful for identifying historical patterns, but it should not be treated as a complete investment strategy.
•	Dividends
•	Company news and announcements
•	Brokerage and transaction costs
•	Taxes
•	Broader market movements
•	Sector-specific events
•	Investor risk tolerance
In addition, moving-average signals are based only on historical prices and may generate signals after a trend has already started. Therefore, a Buy or Sell signal should not be interpreted as a guaranteed prediction of future returns.
12. Conclusion
The SQL analysis demonstrates how historical stock data can be transformed into useful trading and trend insights using SQL. The moving-average crossover method produced Buy and Sell signals for all six stocks and helped identify changes in short-term trends.
TVS Motors and Eicher Motors showed the strongest positive full-period price performance before considering the special corporate-action adjustments. After adjusting for the identified bonus issues, TCS and Infosys also showed positive full-period performance.
The analysis also demonstrates the importance of checking data quality before drawing conclusions. The unusually large price movements in TCS and Infosys could have led to misleading conclusions if the corporate actions had not been identified and adjusted.
Overall, moving-average signals can be useful as one analytical indicator, but they should be combined with company fundamentals, corporate actions, market conditions and transaction costs before making an investment decision.
13. Data Preparation Note
The project guide describes 889 trading-day rows for each stock. The MySQL import used for this analysis returned 888 rows per stock. The SQL analysis and results reported above are based on the data actually loaded into the MySQL database and executed successfully.
