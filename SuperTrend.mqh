//+------------------------------------------------------------------+
//|                                                  SuperTrend_.mqh |
//|                                                          LMGFund |
//|                    https://github.com/LMGFund/mwilasfullproof_v2 |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

/*
*  Function: loadHistoryData(MqlRates& historyData[],
                             int hours,
                             ENUM_TIMEFRAMES timeFrame);
*  Function loads history data based on given input
*/
void superTrend_(datetime _time_0,
                 datetime _time_1,
                 datetime& _PREVIOUSCANDLETIME,
                 double _high_1,
                 double _low_1,
                 double _close_1,
                 double& _previousUpperBand,
                 double& _previousLowerBand,
                 double& _PREVIOUSFINALUPPERBAND,
                 double& _PREVIOUSFINALLOWERBAND,
                 int _atrHandler,
                 bool& _isFirstExecution,
                 bool& _isUpTrend,
                 int _MULTIPLIER,
                 color _LOWERBANDCOLOR,
                 color _UPPERBANDCOLOR)
  {
   uint dataPoints_ = 2;

   double averageTrueRangeData_[];
   double lowerBand_;
   double upperBand_;
   double finalLowerBand_;
   double finalUpperBand_;
   double superTrend_ = 0;

   if(_PREVIOUSCANDLETIME != _time_1)
     {
      averageTrueRangeIndicatorData(averageTrueRangeData_,
                                    _atrHandler,
                                    dataPoints_);
      upperBand_ = getBasicUpperBand(_high_1,
                                     _low_1,
                                     _MULTIPLIER,
                                     averageTrueRangeData_[1]);
      lowerBand_ = getBasicLowerBand(_high_1,
                                     _low_1,
                                     _MULTIPLIER,
                                     averageTrueRangeData_[1]);
      finalUpperBand_ = getFinalUpperBand(upperBand_,
                                          _PREVIOUSFINALUPPERBAND,
                                          _close_1);
      finalLowerBand_ = getFinalLowerBand(lowerBand_,
                                          _PREVIOUSFINALLOWERBAND,
                                          _close_1);
      _PREVIOUSCANDLETIME = _time_1;

      if(finalUpperBand_ != 0 &&
         finalLowerBand_ != 0 &&
         _PREVIOUSFINALUPPERBAND != 0 &&
         _PREVIOUSFINALLOWERBAND != 0)
        {
         if(_close_1 > _PREVIOUSFINALUPPERBAND &&
            !_isFirstExecution)
           {
            _isUpTrend = true;
           }

         if(_close_1 < _PREVIOUSFINALLOWERBAND &&
            !_isFirstExecution)
           {
            _isUpTrend = false;
           }

         //Print("_isFirstExecution = ", _isFirstExecution);
         if(_isFirstExecution)
           {
            checkFirstExecutionXOver(_isFirstExecution,
                                     _isUpTrend,
                                     finalUpperBand_,
                                     finalLowerBand_,
                                     _PREVIOUSFINALUPPERBAND,
                                     _PREVIOUSFINALLOWERBAND);
           }
         printSuperTrend(_isFirstExecution,
                         _isUpTrend,
                         finalUpperBand_,
                         finalLowerBand_,
                         _PREVIOUSFINALUPPERBAND,
                         _PREVIOUSFINALLOWERBAND,
                         _time_0,
                         _time_1,
                         _LOWERBANDCOLOR,
                         _UPPERBANDCOLOR);
        }

      _previousUpperBand = upperBand_;
      _previousLowerBand = lowerBand_;
      _PREVIOUSFINALUPPERBAND = finalUpperBand_;
      _PREVIOUSFINALLOWERBAND = finalLowerBand_;
     }
  }

/*
   Basic Upper Band
   Formula: BASIC UPPER BAND = HLA + [ MULTIPLIER * 10-DAY ATR ]
*/
/*
*  Function: getBasicUpperBand(
                     double _high,
                     double _low,
                     int _MULTIPLIER,
                     double _averageTrueRange)
*/
double getBasicUpperBand(
   double _high,
   double _low,
   int _MULTIPLIER,
   double _averageTrueRange)
  {
   double _highLowAverage = (_high + _low) / 2;
   double _basicBand = _highLowAverage + (_MULTIPLIER * _averageTrueRange);

   return _basicBand;
  }

/*
   Basic Lower Band
   Formula: BASIC LOWER BAND = HLA - [ MULTIPLIER * 10-DAY ATR ]
*/
/*
*  Function: getBasicLowerBand(
                     double _high,
                     double _low,
                     int _MULTIPLIER,
                     double _averageTrueRange)
*/
double getBasicLowerBand(
   double _high,
   double _low,
   int _MULTIPLIER,
   double _averageTrueRange)
  {
   double _highLowAverage = (_high + _low) / 2;
   double _basicBand = _highLowAverage - (_MULTIPLIER * _averageTrueRange);

   return _basicBand;
  }

/*
   Get Final Bands
*/
// Get Final Lower Band
/*
   Final Lowerband = If Current Basic Lowerband > Previous Final Lowerband OR
   Previous Close < Previous Final Lowerband Then Current Basic Lowerband Else Previous Final Lowerband
*/
/*
*  Function: getFinalLowerBand(double _currentbasicLowerBand,
                         double _previousFinalLowerBand,
                         double _previousClose)
*/
double getFinalLowerBand(double _currentbasicLowerBand,
                         double _previousFinalLowerBand,
                         double _previousClose)
  {
   double _currentBand;

   if(_currentbasicLowerBand > _previousFinalLowerBand ||
      _previousClose < _previousFinalLowerBand)
     {
      _currentBand = _currentbasicLowerBand;
     }
   else
     {
      _currentBand = _previousFinalLowerBand;
     }

   return _currentBand;
  }

// Get Final Upper Band
/*
   Final Upperband = If Current Basic Upperband < Previous Final Upperband OR
   Previous Close > Previous Final Upperband Then Current Basic Upperband Else Previous Final Upperband
*/
/*
*  Function: getFinalUpperBand(double _currentbasicUpperBand,
                         double _previousFinalUpperBand,
                         double _previousClose)
*/
double getFinalUpperBand(double _currentbasicUpperBand,
                         double _previousFinalUpperBand,
                         double _previousClose)
  {
   double _currentBand;

   if(_currentbasicUpperBand < _previousFinalUpperBand || _previousClose > _previousFinalUpperBand)
     {
      _currentBand = _currentbasicUpperBand;
     }
   else
     {
      _currentBand = _previousFinalUpperBand;
     }

   return _currentBand;
  }

/*
   Check if it the program has been recently run and the crossover has not occured
*/
/*
*  Function: checkFirstExecutionXOver(bool& _isFirstExecution,
                              bool& _isUpTrend,
                              double _finalUpperBand,
                              double _finalLowerBand,
                              double _previousFinalUpperBand,
                              double _previousFinalLowerBand)
*/
void checkFirstExecutionXOver(bool& _isFirstExecution,
                              bool& _isUpTrend,
                              double _finalUpperBand,
                              double _finalLowerBand,
                              double _previousFinalUpperBand,
                              double _previousFinalLowerBand)
  {
   if(_isFirstExecution &&
      (_previousFinalUpperBand >= _finalUpperBand) &&
      (_previousFinalLowerBand <= _finalLowerBand))
     {
      _isFirstExecution = true;
      return ;
     }
   else
     {
      _isFirstExecution = false;
     }

// We are trending down
   if(!_isFirstExecution &&
      (_previousFinalUpperBand >= _finalUpperBand) &&
      _isUpTrend == NULL)
     {
      _isUpTrend = false;
      return ;
     }

// We are trending up
   if(!_isFirstExecution &&
      (_previousFinalLowerBand <= _finalLowerBand) &&
      _isUpTrend == NULL)
     {
      _isUpTrend = true;
      return ;
     }

  }

/*
   Print our super trend
*/
/*
*  Function: printSuperTrend(bool& _isFirstExecution,
                     bool& _isUpTrend,
                     double _finalUpperBand,
                     double _finalLowerBand,
                     double _previousFinalUpperBand,
                     double _previousFinalLowerBand,
                     datetime _time_0,
                     datetime _time_1)
*/
void printSuperTrend(bool& _isFirstExecution,
                     bool& _isUpTrend,
                     double _finalUpperBand,
                     double _finalLowerBand,
                     double _previousFinalUpperBand,
                     double _previousFinalLowerBand,
                     datetime _time_0,
                     datetime _time_1,
                     color _LOWERBANDCOLOR,
                     color _UPPERBANDCOLOR)
  {
   string _upperBandName = TimeToString(_time_1) + "-" + TimeToString(_time_0) + "Upperband";
   string _lowerBandName = TimeToString(_time_1) + "-"+TimeToString(_time_0) + "Lowerband";

   if(_isFirstExecution && _isUpTrend == NULL)
     {
      drawBand(_previousFinalUpperBand, _time_1, _finalUpperBand, _time_0, _upperBandName, clrAqua);
      drawBand(_previousFinalLowerBand, _time_1, _finalLowerBand, _time_0, _lowerBandName, clrAqua);
     }

   if(!_isFirstExecution && _isUpTrend)
     {
      drawBand(_previousFinalLowerBand, _time_1, _finalLowerBand, _time_0, _lowerBandName, _LOWERBANDCOLOR);
     }

   if(!_isFirstExecution && !_isUpTrend)
     {
      drawBand(_previousFinalUpperBand, _time_1, _finalUpperBand, _time_0, _upperBandName, _UPPERBANDCOLOR);
     }
  }

//+------------------------------------------------------------------+
