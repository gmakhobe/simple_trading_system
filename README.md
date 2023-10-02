# Mwila's Bulletproof

Mwila's Bulletproof is an expert advisor designed to analyze price using simple moving averages and super trend indicators. This guide will explain how to install and configure the expert advisor for optimal performance.

## Expert Advisor Installation
### NB: Set a chart to either 15 minutes or Lower Time Frame Used when operating the Expert Advisor.
Please follow the steps below to install the live version of the expert advisor:

1. Download the "name-version number-live.ex5" Expert Advisor file to your computer or laptop. (Note: The installation process may differ for Mac users)
![Downloads EA](http://localhost/installations/mwillasbulletproof/EA-Installation-Step-1.jpg)
2. Open the MT5 platform and navigate to files on the top menu bar.
3. Click on “open file data” on the Files menu.
![Downloads EA](http://localhost/installations/mwillasbulletproof/EA-Installation-Step-3.jpg)
4. In the file window that appears, navigate to MQL5 and then click on Experts.
5. Copy and paste the "name-version number-live.ex5" file into this Experts folder.
![Downloads EA](http://localhost/installations/mwillasbulletproof/EA-Installation-Step-5.jpg)
6. Return to the MT5 platform and activate the "Algo Trading" option. This will display a green play button.
![Downloads EA](http://localhost/installations/mwillasbulletproof/EA-Installation-Step-6.jpg)
7. Open the navigator window in MT5.
8. Right-click on "Expert Advisors" and select "Refresh." The installed expert advisor will appear in the list. Drag it onto the chart of the desired symbol.  
Before installation:
![Downloads EA](http://localhost/installations/mwillasbulletproof/EA-Installation-Step-8.jpg)  
After installation:
![Downloads EA](http://localhost/installations/mwillasbulletproof/EA-Installation-Step-8-2.jpg)  

## Expert Advisor Settings
After dragging the expert advisor onto the desired chart in the MetaTrader 5 terminal, a pop-up window with two tabs, "Common" and "Inputs," will appear. These settings are crucial for the expert advisor's functionality.  

### "Common" - tab
This section contains common options, usually two but sometimes more or less. Before clicking "OK" or switching to a different tab, ensure that all options are ticked, as shown in the example below.  
![EA Common Settings](http://localhost/installations/mwillasbulletproof/EA-Settings-Common-1.jpg)  


### "Inputs" - tab
This tab includes settings that influence the behavior of the expert advisor. The screenshot below displays all the input settings.  
![EA Input Settings](http://localhost/installations/mwillasbulletproof/EA-Settings-Input-1.jpg)  


The input tab are presented below with sub-headings being variables and body(value) being the explaination of the variable.

#### Breakdown of Variables and Inputs
##### Variable: Lower Time Frame Lookback
---
This variable accepts an integer value greater than or equal to 1. It determines the lookback period for analysis on the lower time frame.

##### Variable: Lower Time Frame Multiplier
---
This variable accepts an integer value greater than or equal to 1. It is used as a multiplier when calculating values to build a supertrend on the lower time frame.  

##### Variable: Higher Time Frame Lookback
---
This variable accepts an integer value greater than or equal to 1. It determines the lookback period for analysis on the higher time frame.  

##### Variable: Higher Time Frame Multiplier
---
This variable takes in an integer from 1, It is used as a multiplier when calculating values to build a supertrend.

##### Variable: Percentage to Risk
---
This is a decimal number that specifies the percentage to be risked on a current account per trade. For example, the amount to be risked on a trade can be 1.0, reflecting 1% risk, or 4.6, reflecting 4.6% risk per trade.  

##### Variable: Risk to Reward
---
This is a decimal number that specifies the reward of the trade in relation to its risk. For example, an expected reward can be set to 3 or 7 times the loss.  

##### Variable: Start of Session 8 = 8:00
---
This should be an integer representing the hour of the day when the Expert Advisor should open a trade. In this case, when the value is 8, it means that a position will start being executed from 8:00 server time.  

##### Variable: End of Session 22 = 22:00
---
This should be an integer representing the hour of the day when the Expert Advisor should stop opening trades. In this case, when the value is 22, positions will stop being executed from 22:00 server time.  

##### Variable: End of session 22 = 22:00
---
This should be an integer in which it reflects from what hour of the day should the Expert Advisor stop opening trades.

In the current case when a value is 8 this means that positions will stop being executed from 22:00 server time.  

##### Variable: Open Trade if Stop is Greater than this Value
---
This value should be an integer. It represents the minimum stop loss value in pips for the Expert Advisor to open a trade. If the stop loss is greater than this value, the EA will not open the respective trade. This helps with filtering trades.  

##### Variable: Open Trade if Stop is Less than this Value
---
This value should be an integer. It represents the maximum stop loss value in pips for the Expert Advisor to open a trade. If the stop loss is less than this value, the EA will not open the respective trade. This helps with filtering trades.  

##### Variable: If the Stop is More than MaximumStop, then Use this Value as Stop Loss
---
This variable is part of the filters. Sometimes the Expert Advisor may have a stop loss with a greater than anticipated value (e.g., greater than 200 pips when day trading). In such cases, this value, provided as an integer, helps with using the specified value as the stop loss. This helps with filtering trades.  

##### Variable: If the Stop is More than MaximumStop, then Use this Value as Take Profit
---
This variable is part of the filters. Sometimes the Expert Advisor may have a take profit with a greater than anticipated value (e.g., greater than 400 pips when day trading). In such cases, this value, provided as an integer, helps with using the specified value as the take profit. This helps with filtering trades.  

##### Variable: Lower Time Frame Period
---
This value should be an ENUM_TIMEFRAMES, representing the time frame used to calculate Expert Advisor logic on a lower time frame.  

##### Variable: Higher Time Frame Period
---
This value should be an ENUM_TIMEFRAMES, representing the time frame used to calculate Expert Advisor logic on a higher time frame.  

## Expert Advisor Usage
### NB: Once the Expert Advisor is installed PLEASE do not switch to a different time frame as this will cause logic errors when doing calculations. 
Please note that as of 28 June 2023, below are the supported pairs that should be used when trading using the EA:  
* USDJPY.
* GBPJPY.
* GBPUSD.
* Nasdaq 100.

The Expert Advisor consist of a very easy to understand user interface, this user interface has trend information (Symbol & Text based), control panel and Start-Up information as shown below.  

![Operations EA](http://localhost/installations/mwillasbulletproof/EA-Operations-1.jpg)

### Trend Information
This is a section of the Expert Advisor panel is important because it shows information of the price trend on a lower time frame and higher time frame.  
![Operations EA](http://localhost/installations/mwillasbulletproof/EA-Operations-Trend-Info.jpg)


#### Lower Time Frame
* AV: This reflects the Moving Average of price over a certain duration. When green a trend is bullish and when red a trend is bearish 
* SP: This reflects the Supertrend formular of price over a certain duration. When green a trend is bullish and when red a trend is bearish

#### Higher Time Frame
* AV: This reflects the Moving Average of price over a certain duration. When green a trend is bullish and when red a trend is bearish 
* SP: This reflects the Supertrend formular of price over a certain duration. When green a trend is bullish and when red a trend is bearish

#### Expert Advisor Auto Trade Conditions
During these condiditons the Expert Advisor will automatically open trade however the conditions will be affected by input settings
##### Buy Conditions  

* ###### Lower Time Frame 
* * AV: Green | Bullish  
* * SP: Green | Bullish
* ###### Higher Time Frame 
* * AV: Green | Bullish  
* * SP: Green | Bullish

##### Sell Conditions  

* ###### Lower Time Frame 
* * AV: Red | Bearish  
* * SP: Red | Bearish
* ###### Higher Time Frame 
* * AV: Red | Bearish  
* * SP: Red | Bearish

### Control Panel
This section of the Expert Advisor panel is important because it consists of buttons that control the behavior of the Expert Advisor tjese buttons ranges from allowing the Expert Advisor to auto trade to auto closing all open trades.  
![Operations EA](http://localhost/installations/mwillasbulletproof/EA-Operations-Control-Panel.jpg)  

#### Switch: (Static & Executions) - Controls
This section consist of actions that are triggered and affects the Expert Advisor based on user actions.  

* Auto Trade (When activated: Green button, When deactivated: Red button):  
Deactivated by default | NB: ACTIVATE THIS FOR AUTO TRADING  
This control button is important for allowing the Expert Advisor to automatically open trades on daily basis, when is deactivated it will never open trades automatically when trade conditions are met.
* Open Trade (When triggured: Black button, default: White button):  
This control button is important because of that it opens a position when conditions are met only when a user clicks the button, the stop loss, take profit (RRR defined in Input settings), lot size (Allowed to risk what is defined from Input settings) are set automatically based on business logic and can later be manually adjusted if necessary.  
* Close Trades (When triggured: Black button, default: White button):    
This control button is important for allowing the Expert Advisor to automatically close all open trades for the pair attached on.


#### Automated Action: (Dynamic)
This section consist of actions that are automated and the Expert Advisor can activate them or deactivate them as it wants. 