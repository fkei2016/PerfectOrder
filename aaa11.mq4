//+------------------------------------------------------------------+
//|                                                        aaa11.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 LimeGreen
//#property indicator_color2 Red
//---- input parameters
//int shift=0;
int i = 0;
int num=0;
int num1=0;
string textVar;
//---- buffers
double ExtMapBuffer1[];
//double ExtMapBuffer2[];
input int magic;
input int sp;
input int tp;
input double lot = 1.0;
input bool IsMartin;
input float aspect;
input float aspect2;
float Count;
int lose;
int RV; //Return Value
int Ticket;
int tortal;
bool Ismartin;
int entrytime;
int updatetime;
bool modifyFlag;

int Winners[20];
int win;

int startMoney;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---


SetIndexStyle(0,DRAW_ARROW);
SetIndexArrow(0,159);
SetIndexBuffer(0, ExtMapBuffer1);
Count = 1;
lose = 0;
Ismartin = false;
entrytime = 0;
updatetime = 0;
modifyFlag = false;
startMoney = AccountBalance();

win = 1;
Winners[0] = 1;
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
int limit;
limit=1500;
for(int i=limit; i>=0; i--)
{
	ObjectDelete(""+i);
}	
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  
  int i = 0;
  int num=0;
  int num1=0;
  
  
  

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
   
   
   int array[9] = {1,1,2,3,5,8,13,21,34,55};
   
   
   
   if(CurrentPosition == 0)
   {
      if(Ismartin == true)
      {
         RV = OrderSelect(Ticket,SELECT_BY_TICKET);
         // StopLoss
         if(OrderProfit() < -100 * Count * lot)
         {
            Count ++;
            lose ++;
            Ismartin = false;
            /*if(lose == 3)
            {
               lose = 0;
               Count ++;
            }*/
         }
         // TakeProfit
         else if(OrderProfit() > 100 * Count * lot)
         {
            Count  --;
            Ismartin = false;
            if(Count <= 1)
            {
               Count = 1;
            }
            if(startMoney <= AccountBalance())
            {
               startMoney  = AccountBalance() + 5000;
               //Count = 1;
            }
         }
         else
         {
            Count -= 0.1;
            Ismartin = false;
            if(Count <= 1)
            {
               Count = 1;
            }
            if(startMoney <= AccountBalance())
            {
               startMoney  = AccountBalance() + 5000;
               Count = 1;
            }
         
         }
         Ismartin = false;
      }
      modifyFlag = false;
   }
   else
   {
      updatetime = TimeCurrent();
     //買い時損切ライン格上げ
     /*if(OrderType()==OP_BUY && OrderOpenPrice() < Ask-((tp-75)*Point) && modifyFlag == false)
     {
        OrderModify(OrderTicket(),OrderOpenPrice(),Ask-((tp-100)*Point),OrderTakeProfit(),0,Blue);
        modifyFlag = true;
     }
     //売り時損切ライン格上げ
     if(OrderType()==OP_SELL && OrderOpenPrice() > Bid+((tp-75)*Point) && modifyFlag == false)
     {
        OrderModify(OrderTicket(),OrderOpenPrice(),Bid+((tp-100)*Point),OrderTakeProfit(),0,Blue);
        modifyFlag = true;
     }*/
   }
   if(!IsMartin)
      Count = 1;

   if(TimeCurrent() > updatetime + 900)
   {
   
   updatetime = TimeCurrent();
   //ObjectsDeleteAll();
   
   for(int i=200; i>=0; i--)
   {
   
    ObjectDelete(""+i);
   
    if(Close[i+1]<Close[i+5])
    { 
       num = num + 1;
    }
    else
    {
       num = 0;
    }
    
    double adx = iADX(NULL,0,14,PRICE_CLOSE,MODE_MAIN,1);
    double mdi = iADX(NULL,0,14,PRICE_CLOSE,MODE_MINUSDI	,1);
    double pdi = iADX(NULL,0,14,PRICE_CLOSE,MODE_PLUSDI,1);
	 if (num > 0 && num < 10) 
	 {
		textVar = num;
		ObjectCreate("",i,OBJ_TEXT, 0, Time[i+1],Low[i+1]-5*Point);
      ObjectSetText(""+i, ""+DoubleToStr(num,0), 10, "Arial", Red);
    }
	 if (num == 9) 
	 {
	    ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],Low[i+1]-5*Point );
       ObjectSetText(""+i, ""+DoubleToStr(num,0), 16, "Arial", Red);
	    RV = OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES);
       if(CurrentPosition != 0 && OrderType()==OP_SELL)
       {
          OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
       }
    }
    else if((Close[i+1]<Close[i+5])&& num>=10)
	 {
		ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],Low[i+1]-5*Point );
      ObjectSetText(""+i, ""+DoubleToStr(num,0), 10, "Arial", Orange);				
	 }
	 
	 				 
	 if(num >= 9 && i == 0 && CurrentPosition ==0 && Zigzag(aspect,aspect2) == 1/*((adx >= 34 && Zigzag() == 1) || (adx <= 33 && adx >= 25))*/)
	 {
	    Ticket = OrderSend(Symbol(), OP_BUY, lot * Count, Ask, 3, Ask-(sp*Point),Ask+(tp*Point), "Buy", magic, 0, Blue);
	    Ismartin = true;
	    entrytime = TimeCurrent();
	    updatetime = TimeCurrent();
	 }

    if(Close[i+1]>Close[i+5]) num1 = num1 + 1; 
    else num1 = 0;

	 if (num1 > 0 && num1 < 10) 
	 {
		textVar = num1;
		ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],High[i+1]+10*Point );
      ObjectSetText(""+i, ""+DoubleToStr(num1,0), 10, "Arial", RoyalBlue);
	 }
	 if (num1 == 9) 
	 {
	    ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],High[i+1]+10*Point );
       ObjectSetText(""+i, ""+DoubleToStr(num1,0), 16, "Arial", RoyalBlue);
		 RV = OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES);
       if(CurrentPosition != 0 && OrderType()==OP_BUY)
       {
          OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
       }
        
    }
    else if((Close[i+1]>Close[i+5])&& num1>=10)
    {
		ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],High[i+1]+10*Point );
      ObjectSetText(""+i, ""+DoubleToStr(num1,0), 10, "Arial", LightSkyBlue);
    }				
    
    if(num1 >= 9 && i == 0 && CurrentPosition ==0 && Zigzag(aspect,aspect2) == 2/*((adx >= 34 && Zigzag() == 2) || (adx <= 33 && adx >= 25))*/)
    {
       Ticket = OrderSend(Symbol() ,OP_SELL, lot * Count, Bid, 3,Bid+(sp*Point),Bid-(tp*Point), "Sella", magic, 0, Blue);
       Ismartin = true;
       entrytime = TimeCurrent();
       updatetime = TimeCurrent();
    }
    
   }
   }
   
  }
  
  
  
int Zigzag(float aspect1,float aspect2)
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
         
      string obj_name = "testobj";
      int    chart_id = 0;
      
      ObjectDelete(obj_name);                                             // オブジェクト削除

      ObjectCreate(obj_name,                                     // オブジェクト作成
                    OBJ_FIBO,                                             // オブジェクトタイプ
                    0,                                                       // サブウインドウ番号
                    old_time[2],                                               // 2番目の時間のアンカーポイント
                    zzArray[2],                                              // 2番目の価格のアンカーポイント
                    old_time[1],                                               // 3番目の時間のアンカーポイント
                    zzArray[1]                                               // 3番目の価格のアンカーポイント
                    );
    
      ObjectSetInteger(chart_id,obj_name,OBJPROP_COLOR,clrYellow);    // ラインの色設定
      ObjectSetInteger(chart_id,obj_name,OBJPROP_STYLE,STYLE_SOLID);  // ラインのスタイル設定
      ObjectSetInteger(chart_id,obj_name,OBJPROP_WIDTH,1);              // ラインの幅設定
      ObjectSetInteger(chart_id,obj_name,OBJPROP_BACK,false);           // オブジェクトの背景表示設定
      ObjectSetInteger(chart_id,obj_name,OBJPROP_SELECTABLE,true);     // オブジェクトの選択可否設定
      ObjectSetInteger(chart_id,obj_name,OBJPROP_SELECTED,true);       // オブジェクトの選択状態
      ObjectSetInteger(chart_id,obj_name,OBJPROP_HIDDEN,true);         // オブジェクトリスト表示設定
      ObjectSetInteger(chart_id,obj_name,OBJPROP_ZORDER,0);            // オブジェクトのチャートクリックイベント優先順位

      ObjectSetInteger(chart_id,obj_name,OBJPROP_LEVELCOLOR,0,clrAqua);      // ラインレベルの色設定
             
      double entryPoint = 0;
      double entryPoint2 = 0;
      
      if(zzArray[0] > zzArray[1])
      {
         
         //if((zzArray[2]-zzArray[3])* 1 + zzArray[3] <= Bid)
             //return(0);
            
            
         entryPoint  = ((zzArray[1]-zzArray[2])* (1.00 - aspect1) + zzArray[2]);
         entryPoint2 = ((zzArray[1]-zzArray[2])* (1.00 - aspect2) + zzArray[2]);
         
         Comment("PE "+aspect1+" = "+entryPoint+"\n"+
                 "Bid = "+Bid+"\n"+
                 "Bid-(tp*Point)  = "+(Bid-(tp*Point))+"\n"+
                 "0  "+zzArray[0]+"\n"+
                 "1  "+zzArray[1]+"\n"+
                 "2  "+zzArray[2]+"\n"+
                 "3  "+zzArray[3]+"\n"+
                 "4  "+zzArray[4]+"\n");
     
         //売り
         if(entryPoint  >= Close[0] &&
            entryPoint2 <= Close[0] &&
            (zzArray[1] - zzArray[2]) >= 0.2)
         {
            Print("PE = ",entryPoint);
            Print("Bid = ",Bid);
            Print("Close = ",Close[0]);
            return(2);
         }
      }
      else
      {
        //if((zzArray[3]-zzArray[2])* 1 + zzArray[2] >= Ask)
            //return(0);
        
        entryPoint  = ((zzArray[2]-zzArray[1])* aspect1 + zzArray[1]);
        entryPoint2 = ((zzArray[2]-zzArray[1])* aspect2 + zzArray[1]);
         
        Comment("PE "+aspect1+" = "+entryPoint+"\n"+
                "Ask = "+Ask+"\n"+
                "Ask+(tp*Point) = "+Ask+(tp*Point)+"\n"+
                 "0  "+zzArray[0]+"\n"+
                 "1  "+zzArray[1]+"\n"+
                 "2  "+zzArray[2]+"\n"+
                 "3  "+zzArray[3]+"\n"+
                 "4  "+zzArray[4]+"\n");
         
        //買い
        if(entryPoint  <= Close[0] &&
           entryPoint2 >= Close[0] &&
           (zzArray[2] - zzArray[1]) >= 0.2)
        {
          Print("PE = ",entryPoint);
          Print("ASK = ",Ask);
          Print("Close = ",Close[0]);
          return(1);
        }
      
      }
      
      return(0);
}
//+------------------------------------------------------------------+
