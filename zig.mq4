//+------------------------------------------------------------------+
//|                                                          zig.mq4 |
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
   time = 999;
   string obj_name = "testobj";
    int    chart_id = 0;
    
    ObjectsDeleteAll();                                                // オブジェクト全削除

    ObjectCreate(obj_name,                                     // オブジェクト作成
                 OBJ_EXPANSION,                                             // オブジェクトタイプ
                 0,                                                       // サブウインドウ番号
                 Time[55],                                               // 1番目の時間のアンカーポイント
                 Close[55],                                              // 1番目の価格のアンカーポイント
                 Time[40],                                               // 2番目の時間のアンカーポイント
                 Close[40],                                              // 2番目の価格のアンカーポイント
                 Time[30],                                               // 3番目の時間のアンカーポイント
                 Close[35]                                               // 3番目の価格のアンカーポイント
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
  double old_pos;
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
   
   if(CurrentPosition == -1 && MathAbs(time - Minute()) >= 15)
   {
      SearchEliot();
      time = Minute();
   }
   else
   {
      if(MathAbs(time-Minute()) >= 15)
      {
         int depth=12;
         int Deviation=5;
         int Backstep=3;
         double zzArray[2];
         int i=0, zzCounter=0;

         while(i<Bars && zzCounter<2)
         {
            double zzPoint=iCustom(Symbol(), 0, "ZigZag", depth, Deviation, Backstep, 0, i);

            if(zzPoint!=0)
            {
               zzArray[zzCounter]=zzPoint;
               zzCounter++;
            }

            i++;
        }
        if(OrderType()==OP_BUY)
        {
           if(zzArray[1] > zzArray[0])
           {
              OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
           }
        }
        if(OrderType()==OP_SELL)
        {
           if(zzArray[1] < zzArray[0])
           {
              OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
           }
        }
      }
   }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//
//関数名 SearchEliot
//
//内容 エリオット波動を感知後トレード開始
//
//引数 なし
//
//戻り値　なし
//+------------------------------------------------------------------+
void SearchEliot()
{
   int depth=12;
   int Deviation=5;
   int Backstep=3;

   double zzArray[6];
   int i=0, zzCounter=0;
   
   while(i<500 && zzCounter<6)
   {
      double zzPoint=iCustom(Symbol(), 0, "ZigZag", depth, Deviation, Backstep, 0, i);

      if(zzPoint!=0)
      {
         zzArray[zzCounter]=zzPoint;
         zzCounter++;
      }

      i++;
   } 
   Comment(zzArray[0]+"\n"+
   zzArray[1]+"\n"+
   zzArray[2]+"\n"+
   zzArray[3]+"\n"+
   zzArray[4]+"\n"+
   zzArray[5]);
   
  if(zzArray[5] < zzArray[4]&&
     zzArray[4] > zzArray[3]&&
     zzArray[5] < zzArray[3]&&
     MathAbs(zzArray[5]-zzArray[4]) < MathAbs(zzArray[3]-zzArray[2])&&
     zzArray[4] < zzArray[1])
     {
        /*Print("AAAAAA 0="+zzArray[0]+" 1="+
   zzArray[1]+" 2="+
   zzArray[2]+" 3="+
   zzArray[3]+" 4="+
   zzArray[4]+" 5="+
   zzArray[5]);*/
        //OrderSend(Symbol(), OP_BUY, 5, Ask, 3, zzArray[1],0, "Buy", 0, 0, Blue);
     }
     
  /*if(zzArray[5] > zzArray[4]&&
     zzArray[4] < zzArray[3]&&
     zzArray[5] > zzArray[3]&&
     MathAbs(zzArray[5]-zzArray[4]) < MathAbs(zzArray[3]-zzArray[2])&&
     zzArray[4] > zzArray[1]&&
     zzArray[1] != old_pos)
     {
        Print("AAAAAA 0="+zzArray[0]+" 1="+
   zzArray[1]+" 2="+
   zzArray[2]+" 3="+
   zzArray[3]+" 4="+
   zzArray[4]+" 5="+
   zzArray[5]);
        OrderSend(Symbol() ,OP_SELL, 5, Bid, 3,zzArray[1] + 0.1, 0, "Sella", 0, 0, Blue);
        old_pos = zzArray[1];
     }*/
     /*(0.5  <= MathAbs(zzArray[5]-zzArray[4]) / MathAbs(zzArray[4]-zzArray[3]))&& //第2波の長さは第1波の0.5倍か0.6倍
     (0.65 >= MathAbs(zzArray[5]-zzArray[4]) / MathAbs(zzArray[4]-zzArray[3]))&&
     (1.6 <= MathAbs(zzArray[3]-zzArray[2]) / MathAbs(zzArray[5]-zzArray[4]))&&// 第3波の長さは第1波の1.618倍以上
     (0.3 >= MathAbs(zzArray[2]-zzArray[1]) / MathAbs(zzArray[3]-zzArray[2]))&&// 第4波の長さは第3波の0.38倍以下に設定する*/
     
     double now_ma;
     now_ma = iMA(NULL,0,90,0,MODE_EMA,PRICE_CLOSE,0);
     
     if(zzArray[5] > zzArray[4]&&
     zzArray[4] < zzArray[3]&&
     zzArray[5] > zzArray[3]&&
     zzArray[4] > zzArray[1]&&
     zzArray[1] != old_pos)
     {
        Print("AAAAAA 0="+zzArray[0]+" 1="+
   zzArray[1]+" 2="+
   zzArray[2]+" 3="+
   zzArray[3]+" 4="+
   zzArray[4]+" 5="+
   zzArray[5]);
        OrderSend(Symbol() ,OP_SELL, 5, Bid, 3,zzArray[1] + 0.1, 0, "Sella", 0, 0, Blue);
        old_pos = zzArray[1];
     }
 }