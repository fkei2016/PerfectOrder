//+------------------------------------------------------------------+
//|                                               PerfectOrder10.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

//---
   time = 0;
   contact = 0;
   entrytime = 0;
   modifyFlag = false;
//---

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
  input int magic;
  input int sp;
  input int tp;
  int time;
  int contact;
  struct MAObject{
  double ma;
  double ma_old;
  int  type;
  bool useEntry;
  };
  
  input bool useM15;
  input bool useM15_75;
  input bool useH1;
  input bool useH4;
  
  input float direction;
  int entrytime;
  bool modifyFlag;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   int CurrentPosition = 0;
   // オーダーチェック（ポジションなどのデータ）
   for(int cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS);
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
      {
         CurrentPosition++;
      }
   }
   //移動平均線
   //上から
   //15分の１０本移動平均線
   //15分の75本移動平均線
   //１時間足の10本移動平均線
   //4時間の10本移動平均線
   MAObject m15;
   m15.ma = iMA(NULL,PERIOD_M15,10,0,MODE_SMA,PRICE_CLOSE,0);
   m15.ma_old = iMA(NULL,PERIOD_M15,10,0,MODE_SMA,PRICE_CLOSE,1);
   m15.type = 1;
   m15.useEntry = useM15;
   
   MAObject m15_75;
   m15_75.ma = iMA(NULL,PERIOD_M15,75,0,MODE_SMA,PRICE_CLOSE,0);
   m15_75.ma_old = iMA(NULL,PERIOD_M15,75,0,MODE_SMA,PRICE_CLOSE,1);
   m15_75.type = 2;
   m15_75.useEntry = useM15_75;
   
   MAObject h1;
   h1.ma = iMA(NULL,PERIOD_H1,10,0,MODE_SMA,PRICE_CLOSE,0);
   h1.ma_old = iMA(NULL,PERIOD_H1,10,0,MODE_SMA,PRICE_CLOSE,1);
   h1.type = 3;
   h1.useEntry = useH1;
   
   MAObject h4;
   h4.ma = iMA(NULL,PERIOD_H4,10,0,MODE_SMA,PRICE_CLOSE,0);
   h4.ma_old = iMA(NULL,PERIOD_H4,10,0,MODE_SMA,PRICE_CLOSE,1);
   h4.type = 4;
   h4.useEntry = useH4;
   
   double maM15_old = iMA(NULL,PERIOD_M15,10,0,MODE_SMA,PRICE_CLOSE,5);
   double maH1_old = iMA(NULL,PERIOD_H1,10,0,MODE_SMA,PRICE_CLOSE,5);
   double maM15_75_old = iMA(NULL,PERIOD_M15,75,0,MODE_SMA,PRICE_CLOSE,5);
   double maH4_old = iMA(NULL,PERIOD_H4,10,0,MODE_SMA,PRICE_CLOSE,5);

   //Bears Power
   double bear_now = iBearsPower(NULL,0,13,PRICE_CLOSE,0);
   double bear_old = iBearsPower(NULL,0,13,PRICE_CLOSE,2);
   
   //Bulls Power
   double bull_now = iBullsPower(NULL,0,13,PRICE_CLOSE,0);
   double bull_old = iBullsPower(NULL,0,13,PRICE_CLOSE,2);


   //コメント表示用
   Comment("" ,"\n",
          "maM15         = ", m15.ma ,"\n",
          "maH1           = ", h1.ma,"\n",
          "maM15_75    = ", m15_75.ma,"\n",
          "maH4           = ", h4.ma,"\n",
          "maM15_old2  = ", m15_75.ma_old,"\n",
          "Close[1]        = ", Close[1],"\n"
          );
          
   double result = iRSI(NULL,0,14,PRICE_CLOSE,0);
   
   //エントリー処理
   if(CurrentPosition == 0 && MathAbs(Minute() - time) >= 15)
   {
      //移動平均線に触れたか
      contact = EntryContactMA(m15,m15_75,h1,h4);
      
      //買いポジション
      if(bear_now > bear_old &&
         bull_now > bull_old &&
         CheckParfectOrder(PERIOD_M5,5,14,20,0) == 1 &&
         h1.ma > h1.ma_old &&
         m15_75.ma > m15_75.ma_old &&
         contact != 0 /*&&
         contact != MAHigt(m15.ma,m15_75.ma,h1.ma,h4.ma)*/)
        {
          OrderSend(Symbol(), OP_BUY, 1.0, Ask, 3, Ask-(sp*Point),Ask+(tp*Point), "Buy", magic, 0, Blue);
          entrytime = TimeCurrent();
          modifyFlag = false;
          
          Print("maH4 = ",h4.ma);
          Print("maH4_old = ",h4.ma_old);
          
        }
      //売りポジション
      if(
         //bear_now > 0 && bull_now > 0 &&
         bear_now < bear_old &&
         bull_now < bull_old &&
         CheckParfectOrder(PERIOD_M5,5,14,20,0) == 2 &&
         h1.ma < h1.ma_old &&
         m15_75.ma < m15_75.ma_old &&
         contact != 0 /*&&
         contact != MALow(m15.ma,m15_75.ma,h1.ma,h4.ma)*/)
         {
          OrderSend(Symbol() ,OP_SELL, 1.0, Bid, 3,Bid+(sp*Point),Bid-(tp*Point), "Sella", magic, 0, Blue);
          entrytime = TimeCurrent();
          modifyFlag = false;
         
           Print("maH4 = ",h4.ma);
           Print("maH4_old = ",h4.ma_old);
         }
    }
   //決済処理
   else if(CurrentPosition != 0)
   {
     if(OrderType()==OP_BUY)
     {
        if(CloseContactMA(m15,m15_75,h1,h4,contact,OrderType()) == true &&
           TimeCurrent() > entrytime + 300)
        {
           OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
           time = Minute();  
        }
     }
     if(OrderType()==OP_SELL)
     {
        if(CloseContactMA(m15,m15_75,h1,h4,contact,OrderType()) == true &&
           TimeCurrent() > entrytime + 300)
        {
           OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
           time = Minute();  
        }
     }
     //買い時損切ライン格上げ
     if(OrderType()==OP_BUY && OrderOpenPrice() < Ask-(150*Point) && modifyFlag == false)
     {
        OrderModify(OrderTicket(),OrderOpenPrice(),Ask-(100*Point),OrderTakeProfit(),0,Blue);
        modifyFlag = true;
     }
     //売り時損切ライン格上げ
     if(OrderType()==OP_SELL && OrderOpenPrice() > Bid+(150*Point) && modifyFlag == false)
     {
        OrderModify(OrderTicket(),OrderOpenPrice(),Bid+(100*Point),OrderTakeProfit(),0,Blue);
        modifyFlag = true;
     }
   }
   //例外処理
   else
   {

   }
   
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//
//関数名 CheckParfectOrder
//
//内容 n時間足でパーフェクトオーダーが発生しているかをチェックする
//
//引数 int timeframe  何分足か
//     int EMA1       短期日線
//     int EMA2       中期日線
//     int EMA3       長期日線
//     int timeshift  何本前か
//
//戻り値　false:何も発生していない　1:買いのパーフェクトオーダー　2:売りのパーフェクトオーダー
//+------------------------------------------------------------------+
int CheckParfectOrder(int timeframe, int EMA1, int EMA2, int EMA3, int timeshift)
{
  double now_fast_ma;
  double now_midle_ma;
  double now_slow_ma;
   
  //短期日線
  now_fast_ma =  iMA(NULL,timeframe,EMA1,0,MODE_SMA,PRICE_CLOSE,timeshift);
  //中間日線
  now_midle_ma =  iMA(NULL,timeframe,EMA2,0,MODE_SMA,PRICE_CLOSE,timeshift);
  //長期日線
  now_slow_ma = iMA(NULL,timeframe,EMA3,0,MODE_SMA,PRICE_CLOSE,timeshift);

  if(now_fast_ma > now_midle_ma &&
     now_midle_ma> now_slow_ma)
     return 1;

  if(now_fast_ma < now_midle_ma&&
     now_midle_ma < now_slow_ma)
     return 2;  


  return false;
}



int EntryContactMA(MAObject &ma1, MAObject &ma2, MAObject &ma3, MAObject &ma4)
{
    MAObject object[4];
    object[0] = ma1;
    object[1] = ma2;
    object[2] = ma3;
    object[3] = ma4;
    
    MAObject sort;
    
    /*Print("object 1 = ",object[0].ma);
    Print("object 2 = ",object[1].ma);
    Print("object 3 = ",object[2].ma);
    Print("object 4 = ",object[3].ma);*/
    
    //ソート
    for(int i =0; i < 4; i++)
    {
        for(int j =0; j < 4; j++)
        {
            if(object[i].ma < object[j].ma)
            {
               sort = object[i];
               object[i] = object[j];
               object[j] = sort;
            }
        }
    }
    
    float a = object[3].ma - object[2].ma;
    float a2 = object[2].ma - object[1].ma;
    float a3 = object[1].ma - object[0].ma;
    
    
    /*Print("object 1新 = ",object[0].ma);
    Print("object 2新 = ",object[1].ma);
    Print("object 3新 = ",object[2].ma);
    Print("object 4新 = ",object[3].ma);
    
    
    Print("a 差 = ",a);
    Print("a2 差 = ",a2);
    Print("a3 差 = ",a3);*/
    
    
    //買いの場合
    if(Close[1] > object[3].ma_old &&
       Close[0] < object[3].ma &&
       a > direction &&
       object[3].useEntry == true)
       return(object[3].type);
    
    if(Close[1] > object[2].ma_old &&
       Close[0] < object[2].ma &&
       a2 > direction &&
       object[2].useEntry == true)
       return(object[2].type);
    
    if(Close[1] > object[1].ma_old &&
       Close[0] < object[1].ma &&
       a3 > direction &&
       object[1].useEntry == true)
       return(object[1].type);
    
    if(Close[1] > object[0].ma_old &&
       Close[0] < object[0].ma &&
       object[0].useEntry == true)
       return(object[0].type);
       
       
       
    //売りの場合
    if(Close[1] < object[3].ma_old &&
       Close[0] > object[3].ma &&
       object[3].useEntry == true)
       return(object[3].type);
       
    if(Close[1] < object[2].ma_old &&
       Close[0] > object[2].ma &&
       a > direction &&
       object[2].useEntry == true)
       return(object[2].type);
    
    if(Close[1] < object[1].ma_old &&
       Close[0] > object[1].ma &&
       a2 > direction &&
       object[1].useEntry == true)
       return(object[1].type);
    
    if(Close[1] < object[0].ma_old &&
       Close[0] > object[0].ma &&
       a3 > direction &&
       object[0].useEntry == true)
       return(object[0].type);
       
       
       
    /*if((Close[1] < object[3].ma_old &&
       Close[0] > object[3].ma) ||
       (Close[1] > object[3].ma_old &&
       Close[0] < object[3].ma &&
       a > direction) &&
       object[3].useEntry == true)
       return(object[3].type);
       
       
       
    if((Close[1] < object[2].ma_old &&
       Close[0] > object[2].ma &&
       a > direction) ||
       (Close[1] > object[2].ma_old &&
       Close[0] < object[2].ma &&
       a2 >direction) &&
       object[2].useEntry == true)
       return(object[2].type);
       
       
       
    if((Close[1] < object[1].ma_old &&
       Close[0] > object[1].ma &&
       a2 > direction) ||
       (Close[1] > object[1].ma_old &&
       Close[0] < object[1].ma &&
       a3 > direction) && 
       object[1].useEntry == true)
       return(object[1].type);



    if((Close[1] < object[0].ma_old &&
       Close[0] > object[0].ma &&
       a3 > direction) ||
       (Close[1] > object[0].ma_old &&
       Close[0] < object[0].ma) && 
       object[0].useEntry == true)
       return(object[0].type);*/
       
  return false;
}

bool CloseContactMA(MAObject &ma1, MAObject &ma2, MAObject &ma3, MAObject &ma4, int entrytype, int orderType)
{

    MAObject object[4];
    object[0] = ma1;
    object[1] = ma2;
    object[2] = ma3;
    object[3] = ma4;
    
    MAObject sort;
    
    /*Print("object 1 = ",object[0].ma);
    Print("object 2 = ",object[1].ma);
    Print("object 3 = ",object[2].ma);
    Print("object 4 = ",object[3].ma);*/
    
    //ソート
    for(int i =0; i < 4; i++)
    {
        for(int j =0; j < 4; j++)
        {
            if(object[i].ma < object[j].ma)
            {
               sort = object[i];
               object[i] = object[j];
               object[j] = sort;
            }
        }
    }
    
    float a = object[3].ma - object[2].ma;
    float a2 = object[2].ma - object[1].ma;
    float a3 = object[1].ma - object[0].ma;
    
    int typeNum;
    for(int i =0; i < 4; i++)
    {
       if(object[i].type == entrytype)
       {
          typeNum = i;
       }
    }
    
    switch(typeNum)
    {
    
      case 0:
        if(orderType == OP_BUY)
        {
           if(object[1].ma < Close[0])
           return true;
        }
        if(orderType == OP_SELL)
        {
           if(object[1].ma_old < Close[1])
           return true;
        }
      break;
    
      case 1:
        if(orderType == OP_BUY)
        {
           if(object[2].ma < Close[0])
           return true;
           
           if(object[0].ma_old > Close[1])
           return true;
        
        }
        if(orderType == OP_SELL)
        {
           if(object[0].ma > Close[0])
           return true;
           
           if(object[2].ma_old < Close[1])
           return true;
        }
      break;
    
      case 2:
        if(orderType == OP_BUY)
        {
          if(object[3].ma < Close[0])
          return true;
          
          if(object[1].ma_old > Close[1])
          return true;
        
        }
        if(orderType == OP_SELL)
        {
          if(object[1].ma > Close[0])
          return true;
          
          if(object[3].ma_old > Close[1])
          return true;
        }
      break;
    
      case 3:
        if(orderType == OP_BUY)
        {
           if(object[2].ma_old > Close[1])
           return true;
        }
        if(orderType == OP_SELL)
        {
           if(object[2].ma > Close[0])
           return true;
        }
      break;
    }
    return false;
  
}












int MAHigt(double ma1,double ma2,double ma3,double ma4)
{
  if(ma1 > ma2 &&
     ma1 > ma3 &&
     ma1 > ma4)
     return(1);
   
  
  if(ma2 > ma1 &&
     ma2 > ma3 &&
     ma2 > ma4)
     return(2);
  
  
  if(ma3 > ma1 &&
     ma3 > ma2 &&
     ma3 > ma4)
     return(3);
  
  
  if(ma4 > ma1 &&
     ma4 > ma2 &&
     ma4 > ma3)
     return(4);
     
     
   return false;

}

int MALow(double ma1,double ma2,double ma3,double ma4)
{
  if(ma1 < ma2 &&
     ma1 < ma3 &&
     ma1 < ma4)
     return(1);
   
  
  if(ma2 < ma1 &&
     ma2 < ma3 &&
     ma2 < ma4)
     return(2);
  
  
  if(ma3 < ma1 &&
     ma3 < ma2 &&
     ma3 < ma4)
     return(3);
  
  
  if(ma4 < ma1 &&
     ma4 < ma2 &&
     ma4 < ma3)
     return(4);
     
  return false;
}

double EntryDifferenceBUY(double ma1,double ma2,double ma3,double ma4)
{
  

  

  return(0);
}