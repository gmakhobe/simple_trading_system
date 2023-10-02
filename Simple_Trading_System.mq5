//+------------------------------------------------------------------+
//|                                                          app.mq5 |
//|                                                          LMGFund |
//|                    https://github.com/LMGFund/mwilasfullproof_v2 |
//+------------------------------------------------------------------+
/* Include Start */
#include "mylib.mqh"
#include "InformationPanel.mqh"
#include <Canvas\Canvas.mqh>
#include <Charts\Chart.mqh>
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>
/* Include End */
/* === Start Global Variables === */
int _Zero = 0;
// Start simple Moving Average Variables
int smaHandlerSellLTF;
int smaHandlerBuyLTF;
int smaHandlerHTFGauge;
input int smaPeriod8 = 8;  // Lower Time Frame SMA Sell period for crossover (Should be smaller)
input int smaPeriod18 = 18; // Lower Time Frame SMA Buy period for crossover (Should be bigger)
input int smaPeriod200 = 200; // Higher Time Frame SMA period
int smaShift = 0;

double PreviousCalculatedSMABuyPriceLTF;
double PreviousCalculatedSMASellPriceLTF;
double PreviousCalculatedSMAGaugePriceLHTF;

bool IsUpTrendSMALTF = NULL;
bool IsUpTrendSMAHTF = NULL;
// End simple Moving Average Variables
// Start SuperTrend Variables
datetime PreviousCandleTimeSuperTrendLTF;
datetime PreviousCandleTimeSuperTrendHTF;

double PreviousCandleHighSuperTrendHTF;
double PreviousUpperBandSuperTrendLTF = 0;
double PreviousLowerBandSuperTrendLTF = 0;
double PreviousFinalUpperBandSuperTrendLTF = 0;
double PreviousFinalLowerBandSuperTrendLTF = 0;
double PreviousUpperBandSuperTrendHTF = 0;
double PreviousLowerBandSuperTrendHTF = 0;
double PreviousFinalUpperBandSuperTrendHTF = 0;
double PreviousFinalLowerBandSuperTrendHTF = 0;

int ATRHandlerLTF;
int ATRHandlerHTF;
input int LookBackPeriodSuperTrendLTF = 10; // Lower Time frame Look back Value
input int MultiplierSuperTrendLTF = 3;      // Lower Time frame Multiplier
input int LookBackPeriodSuperTrendHTF = 10; // Higher Time frame Look back Value
input int MultiplierSuperTrendHTF = 3;      // Higher Time frame Multiplier

bool IsUpTrendSuperTrendLTF = NULL;
bool IsFirstExecutionSuperTrendLTF = true;
bool IsUpTrendSuperTrendHTF = NULL;
bool IsFirstExecutionSuperTrendHTF = true;
bool IsFirstExecutionSMALTF = true;
bool IsFirstExecutionSMAHTF = true;

color LowerBandColorSuperTrendLTF = clrGreen;  // Lower Time frame Lower Band Color
color UpperBandColorSuperTrendLTF = clrBlue;   // Lower Time frame Upper Band Color
color LowerBandColorSuperTrendHTF = clrYellow; // Higher Time frame Lower Band Color
color UpperBandColorSuperTrendHTF = clrWhite;  // Higher Time frame Upper Band Color
color SMABuyLTFBandColor = clrGreen;
color SMASellLTFBandColor = clrBlue;
color SMAGaugeHTFBandColor = clrWhite;
// End SuperTrend Variables

bool IsTrue = true;
/*
   Start: Moderate Signal
*/
input double PercentageToRisk = 1; // Percentage to Risk
input double RiskToRewardRatio = 2; // Risk to reward
/*
   End: Moderate Signal
*/

/*
   Start: Cut off times
*/
input int RiseStart = 8; // Start of the session 8 = 8:00
input int SetStart = 22; // End of the session 22 = 22:00
/*
   End: Cut off times
*/
/*
   Start: Min Stop loss
*/
input double MinimumStop = 10; // Open trade if a stop is greater than this value
input double MaximumStop = 35; // Open trade if a stop is less than this value
input double DefaultStop = 15; // If the stop is more than MaximumStop then use this value as SP
input double DefaultTakeProfit = 30; // If the stop is more than MaximumStop then use this value TP
/*
   End: Start: Min Stop loss
*/

bool testInternet = false;

/*
   Start: Chart timeframes
*/
input ENUM_TIMEFRAMES ChartTimeFrameLTF = PERIOD_M15; // Lower Time frame period
input ENUM_TIMEFRAMES ChartTimeFrameHTF = PERIOD_H1; // Higher Time frame period
ENUM_TIMEFRAMES ChartCurrentTimeFrame;
/*
   End: Chart Timeframes
*/
/* === End Global Variables === */


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   bool _isFalse = false;

   long chartId = 0; // Current Window

   string chartPanelName = "Trend Information"; // Panel Name

   int chartSubWindow = 0; // Current Window
   int upperLeftCorner_x1 = 40;
   int upperLeftCorner_y1 = 40;
   int lowerRightCorner_x2 = 500;
   int lowerRightCorner_y2 = 500;

   IsFirstExecutionSuperTrendLTF = true;
   IsFirstExecutionSuperTrendHTF = true;

   removeAllIndicatorsOnInit();
   TesterHideIndicators(IsTrue);

   smaHandlerSellLTF = lmg_simpleMovingAverageInit(
                          smaPeriod8,
                          smaShift,
                          Symbol(),
                          ChartTimeFrameLTF);
   smaHandlerBuyLTF = lmg_simpleMovingAverageInit(
                         smaPeriod18,
                         smaShift,
                         Symbol(),
                         ChartTimeFrameLTF);
   smaHandlerHTFGauge = lmg_simpleMovingAverageInit(
                           smaPeriod200,
                           smaShift,
                           Symbol(),
                           ChartTimeFrameHTF);

   averageTrueRangeIndicatorInit(ATRHandlerLTF,
                                 LookBackPeriodSuperTrendLTF,
                                 Symbol(),
                                 ChartTimeFrameLTF);
   averageTrueRangeIndicatorInit(ATRHandlerHTF,
                                 LookBackPeriodSuperTrendHTF,
                                 Symbol(),
                                 ChartTimeFrameHTF);
   chartCustomPaintInit();

   if(ATRHandlerLTF == INVALID_HANDLE ||
      ATRHandlerHTF == INVALID_HANDLE ||
      smaHandlerBuyLTF == INVALID_HANDLE ||
      smaHandlerHTFGauge == INVALID_HANDLE ||
      smaHandlerSellLTF == INVALID_HANDLE)
     {
      // An error happened while copy indicator buffer data:
      // One or more indicator hanlders can not be generated
      return (INIT_FAILED);
     }

   if(!InfoPanel.Create(chartId, chartPanelName, chartSubWindow, upperLeftCorner_x1, upperLeftCorner_y1, lowerRightCorner_x2, lowerRightCorner_y2))
     {
      return(INIT_FAILED);
     }
   InfoPanel.SetStartUpValues((RiseStart < 12 ? DoubleToString(RiseStart, 2) + " AM": DoubleToString(RiseStart, 2) + " PM"),
                              (SetStart < 12 ? DoubleToString(SetStart, 2) + " AM": DoubleToString(SetStart, 2) + " PM"),
                              DoubleToString(PercentageToRisk, 2) + "%",
                              "1.0 : " + DoubleToString(RiskToRewardRatio, 2));
//--- Enable Auto Trader Switch and Dynamic Auto Trader
   if(MQLInfoInteger(MQL_TESTER))
     {
      InfoPanel.SetStaticAutoTradeStatus(true);
      InfoPanel.SetDynamicAutoTradeStatus(true);
     }
//--- run application
   InfoPanel.Run();
   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   onClearAllEAInformation();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   /*if (testInternet == false) {
     TestInternet();
     testInternet = true;
   }*/
   int _smaDatePoints = 20;
   int _hoursLTF = 4;
   int _hoursHTF = 8;
   int _zero = 0;
   int _historyDataCountSuperTrendLTF;
   int _historyDataCountSuperTrendHTF;
   int _historyDataCountSMABuyLTF;
   int _historyDataCountSMASellLTF;
   int _historyDataCountSMAGaugeHTF;
   CSymbolInfo infoo;

   double _smaSellLTFData[];
   double _smaBuyLTFData[];
   double _smaGaugeHTFData[];

   bool _isTrue = true;

   MqlRates _historyDataSuperTrendLTF[];
   MqlRates _historyDataSuperTrendHTF[];

   ArraySetAsSeries(_historyDataSuperTrendLTF, IsTrue);
   ArraySetAsSeries(_historyDataSuperTrendHTF, IsTrue);
   ArraySetAsSeries(_smaBuyLTFData, IsTrue);
   ArraySetAsSeries(_smaSellLTFData, IsTrue);
   ArraySetAsSeries(_smaGaugeHTFData, IsTrue);

   switch(IsFirstExecutionSuperTrendLTF && IsFirstExecutionSuperTrendHTF)
     {
      case true:
         /**
          * @brief On first execution, run old data to current time
          *
          */
         simpleMovingAveragesRunOldDatatoCurrent(Symbol(),
                                                 ChartTimeFrameHTF,
                                                 PreviousCandleTimeSuperTrendHTF,
                                                 smaHandlerHTFGauge,
                                                 _isTrue,
                                                 SMAGaugeHTFBandColor);
         superTrendRunOldDataToCurrentTime(Symbol(),
                                           ChartTimeFrameLTF,
                                           _isTrue,
                                           _historyDataSuperTrendLTF,
                                           PreviousCandleTimeSuperTrendLTF,
                                           PreviousUpperBandSuperTrendLTF,
                                           PreviousLowerBandSuperTrendLTF,
                                           PreviousFinalUpperBandSuperTrendLTF,
                                           PreviousFinalLowerBandSuperTrendLTF,
                                           ATRHandlerLTF,
                                           IsFirstExecutionSuperTrendLTF,
                                           IsUpTrendSuperTrendLTF,
                                           MultiplierSuperTrendLTF,
                                           LowerBandColorSuperTrendLTF,
                                           UpperBandColorSuperTrendLTF);
         superTrendRunOldDataToCurrentTime(Symbol(),
                                           ChartTimeFrameHTF,
                                           _isTrue,
                                           _historyDataSuperTrendHTF,
                                           PreviousCandleTimeSuperTrendHTF,
                                           PreviousUpperBandSuperTrendHTF,
                                           PreviousLowerBandSuperTrendHTF,
                                           PreviousFinalUpperBandSuperTrendHTF,
                                           PreviousFinalLowerBandSuperTrendHTF,
                                           ATRHandlerHTF,
                                           IsFirstExecutionSuperTrendHTF,
                                           IsUpTrendSuperTrendHTF,
                                           MultiplierSuperTrendHTF,
                                           LowerBandColorSuperTrendHTF,
                                           UpperBandColorSuperTrendHTF);
         IsFirstExecutionSuperTrendLTF = false;
         IsFirstExecutionSuperTrendHTF = false;
         break;
      case false:
         /**
          * @brief After first time of execution execute typical logic
          *
          */

         loadHistoryData(_historyDataSuperTrendLTF,
                         _hoursLTF,
                         ChartTimeFrameLTF);
         loadHistoryData(_historyDataSuperTrendHTF,
                         _hoursHTF,
                         ChartTimeFrameHTF);
         lmg_simpleMovingAverageData(
            smaHandlerBuyLTF,
            _smaDatePoints,
            _smaBuyLTFData);
         lmg_simpleMovingAverageData(
            smaHandlerSellLTF,
            _smaDatePoints,
            _smaSellLTFData);
         lmg_simpleMovingAverageData(
            smaHandlerHTFGauge,
            _smaDatePoints,
            _smaGaugeHTFData);


         _historyDataCountSuperTrendLTF = ArraySize(_historyDataSuperTrendLTF);
         _historyDataCountSuperTrendHTF = ArraySize(_historyDataSuperTrendHTF);
         _historyDataCountSMABuyLTF = ArraySize(_smaBuyLTFData);
         _historyDataCountSMASellLTF = ArraySize(_smaSellLTFData);
         _historyDataCountSMAGaugeHTF = ArraySize(_smaGaugeHTFData);

         if(_historyDataCountSMABuyLTF > 2 && _historyDataCountSMASellLTF > 2)
           {
            // LTF: Crossover - when 18 sma is below 8 sma = uptrend
            IsUpTrendSMALTF = _smaBuyLTFData[1] < _smaSellLTFData[1] ? true : false;
           }
         if(_historyDataCountSMAGaugeHTF > 2 && _historyDataCountSuperTrendHTF > 2)
           {
            // HTF: Crossover - when 200 sma below price = uptrend
            IsUpTrendSMAHTF = _smaGaugeHTFData[1] < _historyDataSuperTrendHTF[1].close ? true : false;
           }

         if(ArraySize(_historyDataSuperTrendLTF) < 2)
           {
            // not enough history data break.
            break;
           }

         superTrend_(_historyDataSuperTrendLTF[0].time,
                     _historyDataSuperTrendLTF[1].time,
                     PreviousCandleTimeSuperTrendLTF,
                     _historyDataSuperTrendLTF[1].high,
                     _historyDataSuperTrendLTF[1].low,
                     _historyDataSuperTrendLTF[1].close,
                     PreviousUpperBandSuperTrendLTF,
                     PreviousLowerBandSuperTrendLTF,
                     PreviousFinalUpperBandSuperTrendLTF,
                     PreviousFinalLowerBandSuperTrendLTF,
                     ATRHandlerLTF,
                     IsFirstExecutionSuperTrendLTF,
                     IsUpTrendSuperTrendLTF,
                     MultiplierSuperTrendLTF,
                     LowerBandColorSuperTrendLTF,
                     UpperBandColorSuperTrendLTF);
         if(ArraySize(_historyDataSuperTrendHTF) < 2)
           {
            // not enough history data break.
            break;
           }
         superTrend_(_historyDataSuperTrendHTF[0].time,
                     _historyDataSuperTrendHTF[1].time,
                     PreviousCandleTimeSuperTrendHTF,
                     _historyDataSuperTrendHTF[1].high,
                     _historyDataSuperTrendHTF[1].low,
                     _historyDataSuperTrendHTF[1].close,
                     PreviousUpperBandSuperTrendHTF,
                     PreviousLowerBandSuperTrendHTF,
                     PreviousFinalUpperBandSuperTrendHTF,
                     PreviousFinalLowerBandSuperTrendHTF,
                     ATRHandlerHTF,
                     IsFirstExecutionSuperTrendHTF,
                     IsUpTrendSuperTrendHTF,
                     MultiplierSuperTrendHTF,
                     LowerBandColorSuperTrendHTF,
                     UpperBandColorSuperTrendHTF);
         InfoPanel.UpdatePictureSignals(IsUpTrendSMALTF, IsUpTrendSuperTrendLTF, IsUpTrendSMAHTF, IsUpTrendSuperTrendHTF);
         onTradeManager(IsUpTrendSMALTF,
                        IsUpTrendSMAHTF,
                        IsUpTrendSuperTrendLTF,
                        IsUpTrendSuperTrendHTF,
                        PreviousFinalLowerBandSuperTrendLTF,
                        PreviousFinalUpperBandSuperTrendLTF);
         break;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void onTradeManager(bool _IsUpTrendSMALTF,
                    bool _IsUpTrendSMAHTF,
                    bool _IsUpTrendSuperTrendLTF,
                    bool _IsUpTrendSuperTrendHTF,
                    double _PreviousFinalLowerBandSuperTrendLTF,
                    double _PreviousFinalUpperBandSuperTrendLTF)
  {
   double _stopLoss = 0;
   double _takeProfit = 0;
   double _zero = 0;
   double _lotSize = 0;
   bool _isRawTakeProfit = false;
   bool _isRawStopLoss = false;
   bool _stopLossIsGreaterThanMax = false;
   bool _switchCanAutoTrade = InfoPanel.GetSwitchAutoTradeStatus();
   bool _dynamicCanBreakEven = InfoPanel.GetDynamicBreakEvenStatus();
   bool _dynamicCanAutoTrade = InfoPanel.GetDynamicAutoTradeStatus();
   bool _executionCanOpenTrade = InfoPanel.GetExecutionCanOpenTradeStatus();
   bool _executeCanCloseTrades = InfoPanel.GetExecutionCanCloseTradesStatus();
   int _signal = 0;

   //Comment("Info: ", InfoPanel.GetDynamicBreakEvenStatus());
   if(IsUpTrendSuperTrendLTF && IsUpTrendSuperTrendHTF && IsUpTrendSMALTF && IsUpTrendSMAHTF)
     {
      _signal = 1; // Buy
     }
   if(!IsUpTrendSuperTrendLTF && !IsUpTrendSuperTrendHTF && !IsUpTrendSMALTF && !IsUpTrendSMAHTF)
     {
      _signal = 2; // Sell
     }
   if(_executionCanOpenTrade == true)
     {
      // Open trade and set the status to false'
      if(_signal == 1)
        {

         _stopLoss = (SymbolInfoDouble(Symbol(), SYMBOL_BID) - PreviousFinalLowerBandSuperTrendLTF) * MathPow(10, symbolDecimalType());
         _takeProfit = _stopLoss * RiskToRewardRatio;

         Print("Before Take Stop Loss: ", _stopLoss);
         Print("Before Take Profit: ", _takeProfit);

         _stopLossIsGreaterThanMax = _stopLoss > MaximumStop;
         _stopLoss = (_stopLossIsGreaterThanMax ? DefaultStop : _stopLoss);
         _takeProfit = (_stopLossIsGreaterThanMax ? DefaultTakeProfit : _takeProfit);
         _lotSize = NormalizeDouble(onPositionSizeCalculate(PercentageToRisk, _stopLoss), 2);

         Print("Take Stop Loss: ", _stopLoss);
         Print("Take Profit: ", _takeProfit);
         Print("Lot Size: ", _lotSize);

         openBuyOrder(Symbol(),
                      _lotSize,
                      _stopLoss,
                      _isRawStopLoss,
                      _takeProfit,
                      _isRawTakeProfit);
         InfoPanel.SetDynamicAutoTradeStatus(false);
        }
      if(_signal == 2)
        {

         _stopLoss = (_PreviousFinalUpperBandSuperTrendLTF - SymbolInfoDouble(Symbol(), SYMBOL_ASK)) * MathPow(10, symbolDecimalType());
         _takeProfit = _stopLoss * RiskToRewardRatio;

         Print("Before Take Stop Loss: ", _stopLoss);
         Print("Before Take Profit: ", _takeProfit);

         _stopLossIsGreaterThanMax = _stopLoss > MaximumStop;
         _stopLoss = (_stopLossIsGreaterThanMax ? DefaultStop : _stopLoss);
         _takeProfit = (_stopLossIsGreaterThanMax ? DefaultTakeProfit : _takeProfit);
         _lotSize = NormalizeDouble(onPositionSizeCalculate(PercentageToRisk, _stopLoss), 2);

         Print("Take Stop Loss: ", _stopLoss);
         Print("Take Profit: ", _takeProfit);

         openSellOrder(Symbol(),
                       _lotSize,
                       _stopLoss,
                       _isRawStopLoss,
                       _takeProfit,
                       _isRawTakeProfit);
        }
      //addTradePosition();
      InfoPanel.SetExecutionCanOpenTradeStatus(false);
     }

   if(symbolTotalPosition() > _zero)
     {

      if(_dynamicCanBreakEven == true)
        {

         onCurrentPositionBEManager();
        }

      if(_executeCanCloseTrades == true)
        {
         // Close Opened trades
         onClosePositions();
         InfoPanel.SetExecutionCanCloseTradesStatus(false);
        }

      Comment("There is running position, is break event active: ", _dynamicCanBreakEven);
      //return;
     }
   if(_switchCanAutoTrade == false)
     {

      Comment("Auto Trade switch is off.");
      return ;
     }
   if(isBeforeCutOff(SetStart) || isAfterCutOff(RiseStart))
     {
      InfoPanel.SetDynamicAutoTradeStatus(true);
      Comment("It is currently during cut off time");
      return;
     }
   if(_dynamicCanAutoTrade == false)
     {

      Comment("Auto trade dynamic is off");
      return;
     }

   Comment(";-)"); // Clear comment layout
   switch(_signal)
     {
      case 1:

         _stopLoss = (SymbolInfoDouble(Symbol(), SYMBOL_BID) - PreviousFinalLowerBandSuperTrendLTF) * MathPow(10, symbolDecimalType());
         _takeProfit = _stopLoss * RiskToRewardRatio;

         Print("Before Take Stop Loss: ", _stopLoss);
         Print("Before Take Profit: ", _takeProfit);

         if(_stopLoss > MinimumStop)
           {

            _stopLossIsGreaterThanMax = _stopLoss > MaximumStop;
            _stopLoss = (_stopLossIsGreaterThanMax ? DefaultStop : _stopLoss);
            _takeProfit = (_stopLossIsGreaterThanMax ? DefaultTakeProfit : _takeProfit);
            _lotSize = NormalizeDouble(onPositionSizeCalculate(PercentageToRisk, _stopLoss), 2);

            Print("Take Stop Loss: ", _stopLoss);
            Print("Take Profit: ", _takeProfit);
            Print("Lot Size: ", _lotSize);

            openBuyOrder(Symbol(),
                         _lotSize,
                         _stopLoss,
                         _isRawStopLoss,
                         _takeProfit,
                         _isRawTakeProfit);
            InfoPanel.SetDynamicAutoTradeStatus(false);
           }
         break;
      case 2:

         _stopLoss = (_PreviousFinalUpperBandSuperTrendLTF - SymbolInfoDouble(Symbol(), SYMBOL_ASK)) * MathPow(10, symbolDecimalType());
         _takeProfit = _stopLoss * RiskToRewardRatio;

         Print("Before Take Stop Loss: ", _stopLoss);
         Print("Before Take Profit: ", _takeProfit);

         if(_stopLoss > MinimumStop)
           {

            _stopLossIsGreaterThanMax = _stopLoss > MaximumStop;
            _stopLoss = (_stopLossIsGreaterThanMax ? DefaultStop : _stopLoss);
            _takeProfit = (_stopLossIsGreaterThanMax ? DefaultTakeProfit : _takeProfit);
            _lotSize = NormalizeDouble(onPositionSizeCalculate(PercentageToRisk, _stopLoss), 2);

            Print("Take Stop Loss: ", _stopLoss);
            Print("Take Profit: ", _takeProfit);

            openSellOrder(Symbol(),
                          _lotSize,
                          _stopLoss,
                          _isRawStopLoss,
                          _takeProfit,
                          _isRawTakeProfit);
            InfoPanel.SetDynamicAutoTradeStatus(false);
           }
         break;
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int symbolTotalPosition()
  {
   /**
    * @brief Return total position trades for the current symbol
    *
    */
   int numberOfPositions = 0;

   for(int positionCounter = 0; positionCounter <= PositionsTotal(); positionCounter++)
     {
      if(Symbol() == PositionGetSymbol(positionCounter))
        {
         numberOfPositions++;
        }
     }

   return numberOfPositions;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void superTrendRunOldDataToCurrentTime(string symbol_,
                                       ENUM_TIMEFRAMES givenTimeFrame_,
                                       bool halfTotalNumberOfHours_,
                                       MqlRates &totalHistory_[],
                                       datetime &prevousCandleTime_,
                                       double &previousUpperBand_,
                                       double &previousLowerBand_,
                                       double &previousFinalUpperBand_,
                                       double &previousFinalLowerBand_,
                                       int atrHandler_,
                                       bool &isFirstExecution_,
                                       bool &isUpTrend_,
                                       int multiplier_,
                                       color lowerBandColor_,
                                       color upperBandColor_)
  {
   int _totalNumberOfHours = (int)convertGivenCandlesToHours(Bars(symbol_, givenTimeFrame_), givenTimeFrame_);
   int _one = 1;
   int _zero = 0;

   if(halfTotalNumberOfHours_ &&
      (_totalNumberOfHours > _one))
     {
      _totalNumberOfHours /= 2;
     }

   loadHistoryData(totalHistory_,
                   _totalNumberOfHours,
                   givenTimeFrame_);

   int _totalHistoryDataPoints = ArraySize(totalHistory_);

   for(int _counter = _zero; _counter < _totalHistoryDataPoints; _totalHistoryDataPoints--)
     {
      int _actualArrayIndex = _totalHistoryDataPoints - 1;
      int _decremetedIndex = _actualArrayIndex - 1;

      superTrend_(totalHistory_[_decremetedIndex].time,
                  totalHistory_[_actualArrayIndex].time,
                  prevousCandleTime_,
                  totalHistory_[_actualArrayIndex].high,
                  totalHistory_[_actualArrayIndex].low,
                  totalHistory_[_actualArrayIndex].close,
                  previousUpperBand_,
                  previousLowerBand_,
                  previousFinalUpperBand_,
                  previousFinalLowerBand_,
                  atrHandler_,
                  isFirstExecution_,
                  isUpTrend_,
                  multiplier_,
                  lowerBandColor_,
                  upperBandColor_);

      if(_decremetedIndex == _zero)
         break;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double convertGivenCandlesToHours(int totalCandles_, ENUM_TIMEFRAMES givenTimeFrame_)
  {
   if(givenTimeFrame_ == PERIOD_M15)
     {
      return ((double)totalCandles_) / 4;
     }
   if(givenTimeFrame_ == PERIOD_M30)
     {
      return ((double)totalCandles_) / 2;
     }
   if(givenTimeFrame_ == PERIOD_H1)
     {
      return ((double)totalCandles_);
     }
   if(givenTimeFrame_ == PERIOD_H2)
     {
      return ((double)totalCandles_) * 2;
     }
   if(givenTimeFrame_ == PERIOD_H4)
     {
      return ((double)totalCandles_) * 4;
     }
   if(givenTimeFrame_ == PERIOD_H4)
     {
      return ((double)totalCandles_) * 24;
     }

   return 24;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void chartCustomPaintInit()
  {
   /**
    * @brief : Print EA Name and Company name on the chart.
    *
    */
   long _chartPropertyChartId = ChartID();

   int _productNameXAxisPosition = 5;
   int _productNameYAxisPosition = 5;
   int _productNameSize = 20;
   int _companyNameXAxisPosition = 5;
   int _companyNameYAxisPosition = 5;
   int _companyNameSize = 10;

   color _chartPropertyChartBackground = clrBlack;

   string _productName = "Simple Trading System";
   string _companyName = "C[]";

   bool _isTimeCorrect = true;
   bool _isFalse = false;

   ChartSetInteger(_chartPropertyChartId, CHART_SHOW_GRID, _isFalse);
   ChartSetInteger(_chartPropertyChartId, CHART_COLOR_BACKGROUND, _chartPropertyChartBackground);
   ChartSetInteger(_chartPropertyChartId, CHART_COLOR_CHART_UP, clrGreen);
   ChartSetInteger(_chartPropertyChartId, CHART_COLOR_CHART_DOWN, clrRed);
   ChartSetInteger(_chartPropertyChartId, CHART_COLOR_CANDLE_BULL, clrWhite);
   ChartSetInteger(_chartPropertyChartId, CHART_COLOR_CANDLE_BEAR, clrBlack);
   ChartSetInteger(_chartPropertyChartId, CHART_COLOR_ASK, clrRed);
   ChartSetInteger(_chartPropertyChartId, CHART_COLOR_BID, clrGreen);
   ChartSetInteger(_chartPropertyChartId, CHART_IS_DOCKED, _isFalse);
   ChartSetInteger(_chartPropertyChartId, CHART_SHOW_BID_LINE, true);
   ChartSetInteger(_chartPropertyChartId, CHART_SHOW_ASK_LINE, true);
   ChartSetInteger(_chartPropertyChartId, CHART_SHOW_ONE_CLICK, _isFalse);
   ChartSetString(_chartPropertyChartId, CHART_EXPERT_NAME, "Mwilas Bulletproof");

   drawText(_chartPropertyChartId,
            _companyName,
            _companyName,
            _companyNameYAxisPosition,
            _productNameYAxisPosition,
            CORNER_RIGHT_LOWER,
            _companyNameSize,
            clrWhite,
            ANCHOR_RIGHT_LOWER);

   drawText(_chartPropertyChartId,
            _productName,
            _productName,
            _productNameXAxisPosition,
            _productNameYAxisPosition,
            CORNER_LEFT_LOWER,
            _productNameSize,
            clrWhite,
            ANCHOR_LEFT_LOWER);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void simpleMovingAveragesRunOldDatatoCurrent(string symbol_,
      ENUM_TIMEFRAMES givenTimeFrame_,
      datetime prevousCandleTime_,
      int smaHandlerHTFGauge_,
      bool halfTotalNumberOfHours_,
      color bandColor_)
  {
   int _totalNumberOfHours = (int)convertGivenCandlesToHours(Bars(symbol_, givenTimeFrame_), givenTimeFrame_);
   int _one = 1;
   int _zero = 0;

   double _smaData[];

   MqlRates totalHistory_[];

   bool _firstExecution = true;
   bool _isTrue = true;

   if(halfTotalNumberOfHours_ &&
      (_totalNumberOfHours > _one))
     {
      _totalNumberOfHours /= 2;
     }

   ArraySetAsSeries(totalHistory_, _isTrue);
   ArraySetAsSeries(_smaData, _isTrue);

   loadHistoryData(totalHistory_,
                   _totalNumberOfHours,
                   givenTimeFrame_);

   int _totalHistoryPriceDataPoints = ArraySize(totalHistory_);

   lmg_simpleMovingAverageData(
      smaHandlerHTFGauge_,
      _totalHistoryPriceDataPoints,
      _smaData);

   for(int _counter = _zero; _counter < _totalHistoryPriceDataPoints; _totalHistoryPriceDataPoints--)
     {
      int _actualArrayIndex = _totalHistoryPriceDataPoints - 1;
      int _decremetedIndex = _actualArrayIndex - 1;

      string _bandName = DoubleToString(_smaData[_actualArrayIndex]) + "-" + DoubleToString(_smaData[_decremetedIndex]) + IntegerToString(_totalHistoryPriceDataPoints) + "SMA Band";

      if(_decremetedIndex == _zero)
        {
         break;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(
   const int id,
   const long &lparam,
   const double &dparam,
   const string &sparam)
  {
   /**
    * @brief Gets called when an action is performed on the chart
    *
    */
   InfoPanel.ChartEvent(id,lparam,dparam,sparam);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double onPositionSizeCalculate(double percentageToRisk_, double stopLossPips_)
  {
   /**
    * @brief Calculates the position size
    *
    */
   double _accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double _percentage = percentageToRisk_ / 100;
   double _pipValue = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE) * 10;
   double _accountPercentage = _accountBalance * _percentage;

   if(Symbol() == "USTECm" || Symbol() == "NASUSD" || Symbol() == "NAS100" || Symbol() == "US100.cash")
     {
      return ((_accountPercentage)/(stopLossPips_ * _pipValue)) / 10;
     }
   return ((_accountPercentage)/(stopLossPips_ * _pipValue));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester(void)
  {

   return fileProcess();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fileProcess()
  {
   double _statsSuccess = 1.0;
   double _statusError = 0.0;
   string fileLocation = "testfile.txt";
   int fileHandle = FileOpen(fileLocation, FILE_READ | FILE_WRITE | FILE_ANSI);

   if(fileHandle == INVALID_HANDLE)
     {
      return (_statusError);
     }

   FileWriteString(fileHandle, "Hello World\r\n");
   FileClose(fileHandle);
   historyData();
   return (_statsSuccess);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void historyData()
  {
   datetime _fromDate = D'01.01.2022';
   datetime _toDate = D'31.12.2022';
   bool _isHostoryOrdersSelected = HistorySelect(_fromDate, _toDate);
   int _historyDeals = HistoryDealsTotal();
   int _historyOrders = HistoryOrdersTotal();
   string fileContents = "{\"data\": [\n";
   MqlRates historyMonths[];
   MqlRates historyWeeks[];
   MqlRates historyDays[];
   
   ArraySetAsSeries(historyMonths, true);
   ArraySetAsSeries(historyWeeks, true);
   ArraySetAsSeries(historyDays, true);

   for(int counter = 0; counter < _historyOrders; counter++)
     {
      ulong _ticket = HistoryOrderGetTicket(counter);
      string _symbol = HistoryOrderGetString(_ticket, ORDER_SYMBOL);
      string _type = (HistoryOrderGetInteger(_ticket, ORDER_TYPE) == ORDER_TYPE_BUY) ? "Buy" : ((HistoryOrderGetInteger(_ticket, ORDER_TYPE) == ORDER_TYPE_SELL) ? "Sell" : "None");
      double _volume = HistoryOrderGetDouble(_ticket, ORDER_VOLUME_INITIAL);
      double _entryPrice = HistoryOrderGetDouble(_ticket, ORDER_PRICE_OPEN);
      double _stopLoss = HistoryOrderGetDouble(_ticket, ORDER_SL);
      double _takeProfit = HistoryOrderGetDouble(_ticket, ORDER_TP);
      string _comment = HistoryOrderGetString(_ticket, ORDER_COMMENT);
      datetime _time = (datetime)HistoryOrderGetInteger(_ticket, ORDER_TIME_DONE);
      
      loadHistoryDataTestVersion(historyMonths, _time, PERIOD_MN1);
      string _prevMonthCandleType = (historyMonths[1].open < historyMonths[1].close ? "Bullish" : "Bearish");
      string _prevMonthDidCurrentTradeOpenInTheBody = onDidCurrentCandleCloseInPreviousCandlesBody(_entryPrice, historyMonths[1].open, historyMonths[1].close);
      string _prevThreeMonthsClosing = onPreviousThreeBarsTrend(historyMonths[1].close, historyMonths[3].close);
      
      loadHistoryDataTestVersion(historyWeeks, _time, PERIOD_W1);
      string _prevWeekCandleType = (historyWeeks[1].open < historyWeeks[1].close ? "Bullish" : "Bearish");
      string _prevWeekDidCurrentTradeOpenInTheBody = onDidCurrentCandleCloseInPreviousCandlesBody(_entryPrice, historyWeeks[1].open, historyWeeks[1].close);
      string _prevThreeWeeksClosing = onPreviousThreeBarsTrend(historyWeeks[1].close, historyWeeks[3].close);
      
      loadHistoryDataTestVersion(historyDays, _time, PERIOD_D1);
      string _prevDayCandleType = (historyDays[1].open < historyDays[1].close ? "Bullish" : "Bearish");
      string _prevDayDidCurrentTradeOpenInTheBody = onDidCurrentCandleCloseInPreviousCandlesBody(_entryPrice, historyDays[1].open, historyDays[1].close);
      string _prevThreeDaysClosing = onPreviousThreeBarsTrend(historyDays[1].close, historyDays[3].close);
      
      fileContents += "  {\r\n";
      fileContents += "     \"Symbol\": \"" + _symbol + "\",\n";
      fileContents += "     \"Type\": \"" + _type + "\",\n";
      fileContents += "     \"Volume\": \"" + DoubleToString(_volume) + "\",\n";
      fileContents += "     \"EntryPrice\": \"" + DoubleToString(_entryPrice) + "\",\n";
      fileContents += "     \"StopLossPrice\": \"" + DoubleToString(_stopLoss) + "\",\n";
      fileContents += "     \"TakeProfitPrice\": \"" + DoubleToString(_takeProfit) + "\",\n";
      fileContents += "     \"Comment\": \"" + _comment + "\",\n";
      fileContents += "     \"Time\": \"" + TimeToString(_time) + "\",\n";
      fileContents += "     \"PrevMonthCandleType\": \"" + _prevMonthCandleType + "\",\n";
      fileContents += "     \"PrevMonthDidCurrentTradeOpenInTheBody\": \"" + _prevMonthDidCurrentTradeOpenInTheBody + "\",\n";
      fileContents += "     \"PrevThreeMonthsClosing\": \"" + _prevThreeMonthsClosing + "\",\n";
      fileContents += "     \"PrevWeekCandleType\": \"" + _prevWeekCandleType + "\",\n";
      fileContents += "     \"PrevWeekDidCurrentTradeOpenInTheBody\": \"" + _prevWeekDidCurrentTradeOpenInTheBody + "\",\n";
      fileContents += "     \"PrevThreeWeeksClosing\": \"" + _prevThreeWeeksClosing + "\",\n";
      fileContents += "     \"PrevDayCandleType\": \"" + _prevDayCandleType + "\",\n";
      fileContents += "     \"PrevDayDidCurrentTradeOpenInTheBody\": \"" + _prevDayDidCurrentTradeOpenInTheBody + "\",\n";
      fileContents += "     \"PrevThreeDaysClosing\": \"" + _prevThreeDaysClosing + "\",\n";
      fileContents += "  },\n";
     }

   fileContents += "]}\r\n";

   string fileLocation = "orders.txt";
   int fileHandle = FileOpen(fileLocation, FILE_READ | FILE_WRITE | FILE_ANSI);

   FileWriteString(fileHandle, fileContents);
   FileClose(fileHandle);

   fileContents = "{\"data\": [\n";

   for(int counter = 0; counter < _historyDeals; counter++)
     {
      ulong _ticket = HistoryDealGetTicket(counter);
      ulong _order = HistoryDealGetInteger(_ticket, DEAL_ORDER);
      string _symbol = HistoryDealGetString(_ticket, DEAL_SYMBOL);
      string _type = (HistoryDealGetInteger(_ticket, DEAL_TYPE) == DEAL_TYPE_BUY ? "Buy" : (HistoryDealGetInteger(_ticket, DEAL_TYPE) == DEAL_TYPE_SELL ? "Sell" : "None"));
      double _volume = HistoryDealGetDouble(_ticket, DEAL_VOLUME);
      double _entryPrice = HistoryDealGetDouble(_ticket, DEAL_PRICE);
      double _stopLoss = HistoryDealGetDouble(_ticket, DEAL_SL);
      double _takeProfit = HistoryDealGetDouble(_ticket, DEAL_PROFIT);
      double _profit = HistoryDealGetDouble(_ticket, DEAL_PROFIT);
      string _comment = HistoryDealGetString(_ticket, DEAL_COMMENT);

      fileContents += "  {\n";
      fileContents += "     \"Order\": \"" + (string)_order + "\",\n";
      fileContents += "     \"Symbol\": \"" + _symbol + "\",\n";
      fileContents += "     \"Type\": \"" + _type + "\",\n";
      fileContents += "     \"Volume\": \"" + DoubleToString(_volume) + "\",\n";
      fileContents += "     \"EntryPrice\": \"" + DoubleToString(_entryPrice) + "\",\n";
      fileContents += "     \"StopLossPrice\": \"" + DoubleToString(_stopLoss) + "\",\n";
      fileContents += "     \"TakeProfitPrice\": \"" + DoubleToString(_takeProfit) + "\",\n";
      fileContents += "     \"Profit\": \"" + DoubleToString(_profit) + "\",\n";
      fileContents += "     \"Comment\": \"" + _comment + "\",\n";
      fileContents += "  },\n";
     }

   string fileLocation2 = "deals.txt";
   int fileHandle2 = FileOpen(fileLocation2, FILE_WRITE);

   fileContents += "]}\r\n";

   FileWriteString(fileHandle2, fileContents);
   FileClose(fileHandle2);
  }

string onPreviousThreeBarsTrend(double candleOneClose, double candleThreeClose)
{

   if (candleThreeClose < candleOneClose) {
      return "Bullish";
   }
   
   if (candleThreeClose > candleOneClose) {
      return "Bullish";
   }
   
   return "Ranging";
}

string onDidCurrentCandleCloseInPreviousCandlesBody(double entryPrice, double open, double close)
{
   string candleType = (open < close ? "Bullish" : "Bearish");
   
   if (candleType == "Bullish")
   {
      return (entryPrice > open && entryPrice < close ? "Yes": "No");
   }
   
   if (candleType == "Bearish")
   {
      return (entryPrice < open && entryPrice > close ? "Yes": "No");
   }
      
   return "NA"; 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void onClearAllEAInformation()
  {
   /**
    * @brief Delete All objects and free memory
    *
    */
   ObjectsDeleteAll(_Zero);
   PreviousCandleTimeSuperTrendLTF = NULL;
   PreviousCandleTimeSuperTrendHTF = NULL;
   PreviousCandleHighSuperTrendHTF = NULL;
   PreviousUpperBandSuperTrendLTF = NULL;
   PreviousLowerBandSuperTrendLTF = NULL;
   PreviousFinalUpperBandSuperTrendLTF = NULL;
   PreviousFinalLowerBandSuperTrendLTF = NULL;
   PreviousUpperBandSuperTrendHTF = NULL;
   PreviousLowerBandSuperTrendHTF = NULL;
   PreviousFinalUpperBandSuperTrendHTF = NULL;
   PreviousFinalLowerBandSuperTrendHTF = NULL;
   ATRHandlerLTF = NULL;
   ATRHandlerHTF = NULL;
   IsUpTrendSuperTrendLTF = NULL;
   IsFirstExecutionSuperTrendLTF = true;
   IsUpTrendSuperTrendHTF = true;
   IsFirstExecutionSuperTrendHTF = NULL;
   IsTrue = NULL;
   _Zero = NULL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void removeAllIndicatorsOnInit()
  {
   int subwindows= (int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);

   for(int i=subwindows; i>=0; i--)
     {
      int indicators=ChartIndicatorsTotal(0,i);

      for(int j=indicators-1; j>=0; j--)
        {
         ChartIndicatorDelete(0,i,ChartIndicatorName(0,i,j));
        }
     }

   ObjectsDeleteAll(_Zero);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void onClosePositions()
  {
   ulong deviation = 100;
   CTrade trade;
   CPositionInfo positionInfo;
   int positionTotal = PositionsTotal();
   int zero = 0;

   for(int mainCounter = positionTotal; mainCounter >= zero; mainCounter--)
     {

      positionInfo.SelectByIndex(mainCounter);
      if(positionInfo.Symbol() != Symbol())
        {

         continue;
        }
      trade.PositionClose(positionInfo.Ticket());
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TestInternet()
  {
   string cookie=NULL,headers;
   char   post[],result[];
   string url="http://liquiditymanagementgroup-analytics-mwilasbulletproof.s3-website-us-east-1.amazonaws.com/JSONDATA/user_list.json";
//--- To enable access to the server, you should add URL "https://finance.yahoo.com"
//--- to the list of allowed URLs (Main Menu->Tools->Options, tab "Expert Advisors"):
//--- Resetting the last error code
   ResetLastError();
//--- Downloading a html page from Yahoo Finance
   int res=WebRequest("GET",url,cookie,NULL,500,post,0,result,headers);
   if(res==-1)
     {
      Print("Error in WebRequest. Error code  =",GetLastError());
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address
      MessageBox("Add the address '"+url+"' to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
     }
   else
     {
      if(res==200)
        {
         for(int counter = 0; counter < ArraySize(result); counter++)
           {
            Print("Charecter: ", CharToString(result[counter]));
           }
        }
      else
         PrintFormat("Downloading '%s' failed, error code %d",url,res);
     }
  }
//+------------------------------------------------------------------+
