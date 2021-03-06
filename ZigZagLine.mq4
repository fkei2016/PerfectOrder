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
    zighigh = 0.0f;
    ziglow = 0.0f;
    IsBUYentry = false;
    IsSELLentry = false;
    modifyFlag = false;
    
    zighigh2 = 0.0f;
    ziglow2 = 0.0f;
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
  double zighigh2;
  double ziglow2;
  bool IsBUYentry;
  bool IsSELLentry;
  bool modifyFlag;
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
   double old_low = ziglow;
   
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
      
      if(zzArray[3] > zzArray[2])
      {
         zighigh = zzArray[3];
         ziglow = zzArray[2];
         
         zighigh2 = zzArray[5];
         ziglow2 = zzArray[4];
      }
      else
      {
         ziglow = zzArray[3];
         zighigh = zzArray[2];
        
         ziglow2 = zzArray[5];
         zighigh2 = zzArray[4];
      }
      
      Comment("zighigh = ",zighigh,"\n",
              "zighigh2 = ",zighigh2,"\n",
              "ziglow = ",ziglow,"\n",
              "ziglow2 = ",ziglow2,"\n");
      
      ObjectsDeleteAll();
  
      ObjectCreate("High",OBJ_HLINE,0,0,zighigh);
      ObjectSet("High",OBJPROP_COLOR,Red);
      ObjectSet("High",OBJPROP_WIDTH,1);
  
      ObjectCreate("Low",OBJ_HLINE,0,0,ziglow);
      ObjectSet("Low",OBJPROP_COLOR,Blue);
      ObjectSet("Low",OBJPROP_WIDTH,1);
      
      ObjectCreate("High2",OBJ_HLINE,0,0,zighigh2);
      ObjectSet("High2",OBJPROP_COLOR,Orange);
      ObjectSet("High2",OBJPROP_WIDTH,1);    
      
      ObjectCreate("Low2",OBJ_HLINE,0,0,ziglow2);
      ObjectSet("Low2",OBJPROP_COLOR,DeepSkyBlue);
      ObjectSet("Low2",OBJPROP_WIDTH,1);
      
      
      
             
      time = Minute();
   }
   
   if(old_high != zighigh) IsBUYentry = true;
   
   if(old_low != ziglow) IsSELLentry = true;
   
   //ポジションを持っていなかったら
   if(CurrentPosition == -1)
   {
      //買い
      if(High[1] >= ziglow &&
         Low[1] <= ziglow &&
         (Open[1] - Close[1]) <= 0 &&
         Volume[1] <= 3500 &&
         ziglow <= zighigh &&
         ziglow <= zighigh2 &&
         ziglow2 <= zighigh &&
         ziglow2 <= zighigh2 &&
         IsBUYentry == true)
      {
         OrderSend(Symbol(), OP_BUY, 1.0, Ask, 3, ziglow-(100*Point),0, "Buy", 0, 0, Blue);
         IsBUYentry = false;
         modifyFlag = false;
      }
         
      //売り
      if(Low[1] <= zighigh &&
         High[1] >= zighigh &&
         (Open[1] - Close[1]) >= 0 &&
         Volume[1] <= 3500 &&
         ziglow <= zighigh &&
         ziglow <= zighigh2 &&
         ziglow2 <= zighigh &&
         ziglow2 <= zighigh2 &&
         IsSELLentry == true)
      {
         OrderSend(Symbol() ,OP_SELL, 1.0, Bid, 3,zighigh+(100*Point),0, "Sella", 0, 0, Blue);
         IsSELLentry = false;
         modifyFlag = false;
      }
      
   }
   //決済
   else
   {
      if(OrderType()==OP_BUY &&
         old_low != ziglow)
      {
         OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
      }
      if(OrderType() == OP_SELL &&
         old_high != zighigh)
      {
         OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
      }
      //買い時損切ライン格上げ（勝利確定ポジションに変更）
      if(OrderType()==OP_BUY && OrderOpenPrice() < Ask-(150*Point) && modifyFlag == false)
      {
         OrderModify(OrderTicket(),OrderOpenPrice(),Ask-(100*Point),OrderTakeProfit(),0,Blue);
         modifyFlag = true;
      }
      //買い時損切ライン格上げ 2（勝利確定ポジションに変更）
      if(/*ProfitSecond == true &&*/ OrderType()==OP_BUY && OrderStopLoss() < Ask-(350*Point) && modifyFlag == true)
      {
         OrderModify(OrderTicket(),OrderOpenPrice(),Ask-(200*Point),OrderTakeProfit(),0,Blue);
         modifyFlag = true;
      }
      //売り時損切ライン格上げ（勝利確定ポジションに変更）
      if(OrderType()==OP_SELL && OrderOpenPrice() > Bid+(150*Point) && modifyFlag == false)
      {
         OrderModify(OrderTicket(),OrderOpenPrice(),Bid+(100*Point),OrderTakeProfit(),0,Blue);
         modifyFlag = true;
      }
      //売り時損切ライン格上げ 2（勝利確定ポジションに変更）
      if(/*ProfitSecond == true &&*/ OrderType()==OP_SELL && OrderStopLoss() > Bid+(350*Point) && modifyFlag == true)
      {
         OrderModify(OrderTicket(),OrderOpenPrice(),Bid+(200*Point),OrderTakeProfit(),0,Blue);
         modifyFlag = true;
      }
   }
}
//+------------------------------------------------------------------+
