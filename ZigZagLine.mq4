//+------------------------------------------------------------------+
//|                                                   ZigZagLine.mq4 |
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
    double zighigh = 0.0f;
    double ziglow = 0.0f;
    bool Isentry = false;
   
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
  int time;
  double zighigh;
  double ziglow;
  bool Isentry;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   int CurrentPosition = -1;
   
   int order_select;
   
    // オーダーチェック（ポジションなどのデータ）
   for(int cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select = OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
         CurrentPosition=cnt;
      }
   }
   
   double old_high = zighigh;
   
   if(MathAbs(time - Minute()) >= 1)
   {
      //ZigZagの頂点と線を引く
      int depth=12;
      int Deviation=5;
      int Backstep=3;

      double zzArray[6];
      int i=0, zzCounter=0;
      
      datetime old_time[6];
      
      while(i<500 && zzCounter<6)
      {
         double zzPoint=iCustom(Symbol(), 0, "ZigZag", depth, Deviation, Backstep, 0, i);
  
         if(zzPoint!=0)
         {
            zzArray[zzCounter]=zzPoint;
            old_time[zzCounter] = Time[i];
            zzCounter++;
         }

            i++;
      }
      
      if(zzArray[4] > zzArray[5])
      {
         zighigh = zzArray[4];
         ziglow = zzArray[5];
      }
      else
      {
         ziglow = zzArray[4];
         zighigh = zzArray[5];
      }
      
      ObjectsDeleteAll();
  
      ObjectCreate("High",OBJ_HLINE,0,0,zighigh);
      ObjectSet("High",OBJPROP_COLOR,Red);
      ObjectSet("High",OBJPROP_WIDTH,1);
  
      ObjectCreate("Low",OBJ_HLINE,0,0,ziglow);
      ObjectSet("Low",OBJPROP_COLOR,Blue);
      ObjectSet("Low",OBJPROP_WIDTH,1);
             
      time = Minute();
   }
   
   if(old_high != zighigh) Isentry = true;
   
   //ポジションを持っていなかったら
   if(CurrentPosition == -1 && Isentry == true)
   {
      Comment("IsEntry = ",Isentry,"\n",
              "high = ",zighigh,"\n",
              "low = ",ziglow);
      //買い
      if(High[1] >= ziglow &&
         Low[1] <= ziglow &&
         (Open[1] - Close[1]) <= 0)
      {
         OrderSend(Symbol(), OP_BUY, 1.0, Ask, 3, Ask-(100*Point),Ask+(100*Point), "Buy", 0, 0, Blue);
         Isentry = false;
      }
         
      //売り
      if(Low[1] <= ziglow &&
         High[1] >= ziglow)
      {
         //OrderSend(Symbol() ,OP_SELL, 1.0, Bid, 3,0,0, "Sella", Bid+(100*Point), Bid-(100*Point), Blue);
      }
      
   }
   //決済
   else
   {
      if(OrderType()==OP_BUY &&
         old_high != zighigh)
      {
         OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
      }
      if(OrderType() == OP_SELL)
      {
         
      }
   }
}
//+------------------------------------------------------------------+
