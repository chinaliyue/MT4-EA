//+------------------------------------------------------------------+
//|                                           简化交易面板.mq4        |
//+------------------------------------------------------------------+
#property copyright "简化交易面板"
#property link      ""
#property version   "1.00"
#property strict

// 事件常量定义
#define CHARTEVENT_OBJECT_ENDCHANGE 2

// EA说明
#property description "简化交易面板EA"
#property description "提供基础交易功能的快捷操作界面"

// 输入参数
input double DefaultLot = 0.01;        // 默认手数
input int    DefaultSL = 200;          // 默认止损点数
input int    DefaultTP = 1000;         // 默认止盈点数
input int    Magic = 888888;           // 魔术数字
input int    TrailingStop = 300;       // 追踪止损点数
input int    TrailingStep = 60;        // 追踪步长
input double PresetLot1 = 0.01;        // 预设交易量1
input double PresetLot2 = 0.02;        // 预设交易量2
input double PresetLot3 = 0.05;        // 预设交易量3
input double PresetLot4 = 0.1;         // 预设交易量4

// 常量定义
#define PANEL_PREFIX "SIMPLE_"
#define PANEL_WIDTH 210
#define PANEL_HEIGHT 420  //面板高度修改
#define BUTTON_HEIGHT 35
#define EDIT_HEIGHT 25
#define GAP 5

// 颜色定义
#define COLOR_BG C'240, 240, 240'      // 背景色
#define COLOR_SELL C'0, 128, 0'        // 卖出按钮
#define COLOR_BUY C'255, 0, 0'     // 买入按钮
#define COLOR_PROFIT C'0, 200, 0'      // 盈利色
#define COLOR_LOSS C'200, 0, 0'        // 亏损色

string Prefix = PANEL_PREFIX;
string lotEdit = Prefix + "LOT";
string slEdit = Prefix + "SL";
string tpEdit = Prefix + "TP";
string trailingEdit = Prefix + "TRAILING";

// 全局变量 - 使用input参数初始化
double currentLot = DefaultLot;
int currentSL = DefaultSL;
int currentTP = DefaultTP;
int currentTrailing = TrailingStop;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // 使用默认值初始化
   currentLot = DefaultLot;
   currentSL = DefaultSL;
   currentTP = DefaultTP;
   currentTrailing = TrailingStop;
   
   CreatePanel();
   EventSetTimer(1);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeleteAllObjects();
   EventKillTimer();
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   UpdatePriceDisplay();
   UpdateProfitDisplay();
   ProcessTrailingStop();
}

//+------------------------------------------------------------------+
//| Chart event function                                             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam == Prefix + "SELL")
      {
         OpenOrder(OP_SELL);
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
      else if(sparam == Prefix + "BUY")
      {
         OpenOrder(OP_BUY);
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
      else if(sparam == Prefix + "BUY_STOP")
      {
         OpenPendingOrder(OP_BUYSTOP);
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
      else if(sparam == Prefix + "SELL_STOP")
      {
         OpenPendingOrder(OP_SELLSTOP);
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
      else if(sparam == Prefix + "BUY_LIMIT")
      {
         OpenPendingOrder(OP_BUYLIMIT);
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
      else if(sparam == Prefix + "SELL_LIMIT")
      {
         OpenPendingOrder(OP_SELLLIMIT);
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
      else if(sparam == Prefix + "CLOSE_ALL")
      {
         CloseAllOrders();
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
      else if(sparam == Prefix + "CLOSE_REVERSE")
      {
         CloseAndReverse();
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
      else if(sparam == Prefix + "DELETE_PENDING")
      {
         DeletePendingOrders();
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
      else if(sparam == Prefix + "LOT_001")
      {
         currentLot = PresetLot1;
         ObjectSetString(0, lotEdit, OBJPROP_TEXT, DoubleToStr(currentLot, 2));
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
      else if(sparam == Prefix + "LOT_01")
      {
         currentLot = PresetLot2;
         ObjectSetString(0, lotEdit, OBJPROP_TEXT, DoubleToStr(currentLot, 2));
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
      else if(sparam == Prefix + "LOT_1")
      {
         currentLot = PresetLot3;
         ObjectSetString(0, lotEdit, OBJPROP_TEXT, DoubleToStr(currentLot, 2));
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
      else if(sparam == Prefix + "LOT_10")
      {
         currentLot = PresetLot4;
         ObjectSetString(0, lotEdit, OBJPROP_TEXT, DoubleToStr(currentLot, 2));
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
   }
   
   if(id == CHARTEVENT_OBJECT_ENDCHANGE)
   {
      if(sparam == lotEdit)
      {
         currentLot = StringToDouble(ObjectGetString(0, lotEdit, OBJPROP_TEXT));
         if(currentLot < 0.01) currentLot = 0.01;
         if(currentLot > 100) currentLot = 100;
         ObjectSetString(0, lotEdit, OBJPROP_TEXT, DoubleToStr(currentLot, 2));
      }
      else if(sparam == slEdit)
      {
         currentSL = (int)StringToInteger(ObjectGetString(0, slEdit, OBJPROP_TEXT));
         if(currentSL < 0) currentSL = 0;
         ObjectSetString(0, slEdit, OBJPROP_TEXT, IntegerToString(currentSL));
      }
      else if(sparam == tpEdit)
      {
         currentTP = (int)StringToInteger(ObjectGetString(0, tpEdit, OBJPROP_TEXT));
         if(currentTP < 0) currentTP = 0;
         ObjectSetString(0, tpEdit, OBJPROP_TEXT, IntegerToString(currentTP));
      }
      else if(sparam == trailingEdit)
      {
         currentTrailing = (int)StringToInteger(ObjectGetString(0, trailingEdit, OBJPROP_TEXT));
         if(currentTrailing < 0) currentTrailing = 0;
         ObjectSetString(0, trailingEdit, OBJPROP_TEXT, IntegerToString(currentTrailing));
      }
   }
}

//+------------------------------------------------------------------+
//| 创建面板                                                         |
//+------------------------------------------------------------------+
void CreatePanel()
{
   // 获取图表尺寸并计算右下角位置
   int chartWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartHeight = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   int x = chartWidth - PANEL_WIDTH - 20;  // 距离右边20像素
   int y = chartHeight - PANEL_HEIGHT - 50; // 距离底部50像素
   
   // 背景
   CreateRectLabel(Prefix + "BG", x-GAP, y-GAP, PANEL_WIDTH, PANEL_HEIGHT, COLOR_BG);
   
   // 一键平仓（包含盈亏显示）
   CreateButton(Prefix + "CLOSE_ALL", x, y, PANEL_WIDTH-20, BUTTON_HEIGHT, "一键平仓 | $0.00", clrRed);
   y += BUTTON_HEIGHT + GAP;
   
   // 预设交易量按钮
   CreateButton(Prefix + "LOT_001", x, y, 46, 25, DoubleToStr(PresetLot1, 2), clrGray);
   CreateButton(Prefix + "LOT_01", x + 47, y, 46, 25, DoubleToStr(PresetLot2, 2), clrGray);
   CreateButton(Prefix + "LOT_1", x + 94, y, 46, 25, DoubleToStr(PresetLot3, 2), clrGray);
   CreateButton(Prefix + "LOT_10", x + 141, y, 44, 25, DoubleToStr(PresetLot4, 2), clrGray);
   y += 30;
   
   // SELL按钮
   CreateButton(Prefix + "SELL", x, y, 60, BUTTON_HEIGHT, "SELL", COLOR_SELL);
   
   // 手数输入
   CreateEdit(lotEdit, x + 65, y, DoubleToStr(currentLot, 2));
   
   // BUY按钮
   CreateButton(Prefix + "BUY", x + 125, y, 60, BUTTON_HEIGHT, "BUY", COLOR_BUY);
   y += BUTTON_HEIGHT + GAP;
   
   // 价格显示区域
   CreateLabel(Prefix + "PRICE1", x, y, "3358.39", clrBlue);
   CreateLabel(Prefix + "SPREAD", x + 65, y, "0.5", clrBlack);
   CreateLabel(Prefix + "PRICE2", x + 125, y, "3358.44", clrRed);
   y += 25;
   
   // 止损设置
   CreateLabel(Prefix + "SL_LABEL", x, y, "止损", clrBlack);
   CreateEdit(slEdit, x + 35, y, IntegerToString(currentSL));
   CreateLabel(Prefix + "TP_LABEL", x + 100, y, "止盈", clrBlack);
   CreateEdit(tpEdit, x + 125, y, IntegerToString(currentTP));
   y += EDIT_HEIGHT + GAP;
   
   // 追踪止损
   CreateLabel(Prefix + "TRAILING_LABEL", x, y, "追踪止损点数", clrBlack);
   CreateEdit(trailingEdit, x + 85, y, IntegerToString(currentTrailing));
   y += EDIT_HEIGHT + GAP;
   
   // 删除挂单
   CreateButton(Prefix + "DELETE_PENDING", x, y, PANEL_WIDTH-20, BUTTON_HEIGHT, "删除挂单", clrPurple);
   y += BUTTON_HEIGHT + GAP;
   
   // 止损单
   CreateLabel(Prefix + "STOP_LABEL", x, y, "止损单", clrBlack);
   y += 20;
   CreateButton(Prefix + "SELL_STOP", x, y, 92, BUTTON_HEIGHT, "卖出止损单", clrGreen);
   CreateButton(Prefix + "BUY_STOP", x + 93, y, 92, BUTTON_HEIGHT, "买入止损单", clrRed);
   y += BUTTON_HEIGHT + GAP;
   
   // 限价单
   CreateLabel(Prefix + "LIMIT_LABEL", x, y, "限价单", clrBlack);
   y += 20;
   CreateButton(Prefix + "SELL_LIMIT", x, y, 92, BUTTON_HEIGHT, "卖出限价单", clrGreen);
   CreateButton(Prefix + "BUY_LIMIT", x + 93, y, 92, BUTTON_HEIGHT, "买入限价单", clrRed);
   y += BUTTON_HEIGHT + GAP;
   
   // 平仓反手
   CreateButton(Prefix + "CLOSE_REVERSE", x, y, PANEL_WIDTH-20, BUTTON_HEIGHT, "平仓反手", clrOrange);
   y += BUTTON_HEIGHT + GAP;
   
   // 实际止损止盈额度显示
   CreateLabel(Prefix + "ACTUAL_SL", x, y, "实际止损: $0.00", clrRed);
   CreateLabel(Prefix + "ACTUAL_TP", x + 100, y, "实际止盈: $0.00", clrGreen);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| 创建按钮                                                         |
//+------------------------------------------------------------------+
void CreateButton(string name, int x, int y, int w, int h, string text, color bg_color)
{
   ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg_color);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrGray);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_STATE, false);
}

//+------------------------------------------------------------------+
//| 创建输入框                                                       |
//+------------------------------------------------------------------+
void CreateEdit(string name, int x, int y, string text)
{
   ObjectCreate(0, name, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, 60);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, 20);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, name, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrWhite);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrGray);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| 创建标签                                                         |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color text_color)
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, name, OBJPROP_COLOR, text_color);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| 创建矩形标签                                                     |
//+------------------------------------------------------------------+
void CreateRectLabel(string name, int x, int y, int w, int h, color bg_color)
{
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg_color);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrGray);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
//| 开仓                                                             |
//+------------------------------------------------------------------+
void OpenOrder(int orderType)
{
   RefreshRates();
   
   double price = (orderType == OP_BUY) ? Ask : Bid;
   double sl = 0, tp = 0;
   
   if(currentSL > 0)
   {
      if(orderType == OP_BUY)
         sl = price - currentSL * Point;
      else
         sl = price + currentSL * Point;
   }
   
   if(currentTP > 0)
   {
      if(orderType == OP_BUY)
         tp = price + currentTP * Point;
      else
         tp = price - currentTP * Point;
   }
   
   int ticket = OrderSend(Symbol(), orderType, currentLot, price, 3, sl, tp, 
                         "简化面板", Magic, 0, (orderType == OP_BUY) ? clrBlue : clrRed);
   
   if(ticket < 0)
   {
      Print("开仓失败，错误代码: ", GetLastError());
   }
   else
   {
      Print("开仓成功，订单号: ", ticket);
   }
}

//+------------------------------------------------------------------+
//| 开挂单                                                           |
//+------------------------------------------------------------------+
void OpenPendingOrder(int orderType)
{
   RefreshRates();
   
   double price = 0;
   double sl = 0, tp = 0;
   
   // 根据订单类型设置价格
   if(orderType == OP_BUYSTOP)
   {
      price = Ask + 50 * Point;  // 买入止损单价格高于当前价
   }
   else if(orderType == OP_SELLSTOP)
   {
      price = Bid - 50 * Point;  // 卖出止损单价格低于当前价
   }
   else if(orderType == OP_BUYLIMIT)
   {
      price = Ask - 50 * Point;  // 买入限价单价格低于当前价
   }
   else if(orderType == OP_SELLLIMIT)
   {
      price = Bid + 50 * Point;  // 卖出限价单价格高于当前价
   }
   
   // 设置止损止盈
   if(currentSL > 0)
   {
      if(orderType == OP_BUYSTOP || orderType == OP_BUYLIMIT)
         sl = price - currentSL * Point;
      else
         sl = price + currentSL * Point;
   }
   
   if(currentTP > 0)
   {
      if(orderType == OP_BUYSTOP || orderType == OP_BUYLIMIT)
         tp = price + currentTP * Point;
      else
         tp = price - currentTP * Point;
   }
   
   string orderTypeStr = "";
   if(orderType == OP_BUYSTOP) orderTypeStr = "买入止损单";
   else if(orderType == OP_SELLSTOP) orderTypeStr = "卖出止损单";
   else if(orderType == OP_BUYLIMIT) orderTypeStr = "买入限价单";
   else if(orderType == OP_SELLLIMIT) orderTypeStr = "卖出限价单";
   
   int ticket = OrderSend(Symbol(), orderType, currentLot, price, 3, sl, tp, 
                         orderTypeStr, Magic, 0, clrYellow);
   
   if(ticket < 0)
   {
      Print("挂单失败，错误代码: ", GetLastError());
   }
   else
   {
      Print("挂单成功，订单号: ", ticket, ", 类型: ", orderTypeStr);
   }
}

//+------------------------------------------------------------------+
//| 平仓所有订单                                                     |
//+------------------------------------------------------------------+
void CloseAllOrders()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         {
            RefreshRates();
            double closePrice = (OrderType() == OP_BUY) ? Bid : Ask;
            
            bool result = OrderClose(OrderTicket(), OrderLots(), closePrice, 3, clrYellow);
            if(!result)
            {
               Print("平仓失败，订单号: ", OrderTicket(), ", 错误代码: ", GetLastError());
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| 删除挂单                                                         |
//+------------------------------------------------------------------+
void DeletePendingOrders()
{
   int deletedCount = 0;
   
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         {
            // 检查是否为挂单类型
            if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP || 
               OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
            {
               bool result = OrderDelete(OrderTicket(), clrYellow);
               if(result)
               {
                  deletedCount++;
                  Print("删除挂单成功，订单号: ", OrderTicket());
               }
               else
               {
                  Print("删除挂单失败，订单号: ", OrderTicket(), ", 错误代码: ", GetLastError());
               }
            }
         }
      }
   }
   
   if(deletedCount > 0)
   {
      Print("共删除 ", deletedCount, " 个挂单");
   }
   else
   {
      Print("没有找到需要删除的挂单");
   }
}

//+------------------------------------------------------------------+
//| 更新价格显示                                                     |
//+------------------------------------------------------------------+
void UpdatePriceDisplay()
{
   RefreshRates();
   ObjectSetString(0, Prefix + "PRICE1", OBJPROP_TEXT, DoubleToStr(Bid, Digits));
   ObjectSetString(0, Prefix + "PRICE2", OBJPROP_TEXT, DoubleToStr(Ask, Digits));
   
   // 计算并显示点差
   double spread = (Ask - Bid) / Point;
   ObjectSetString(0, Prefix + "SPREAD", OBJPROP_TEXT, DoubleToStr(spread, 1));
}

//+------------------------------------------------------------------+
//| 更新盈亏显示                                                     |
//+------------------------------------------------------------------+
void UpdateProfitDisplay()
{
   double totalProfit = 0;
   double totalSLAmount = 0;
   double totalTPAmount = 0;
   
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         {
            totalProfit += OrderProfit() + OrderSwap() + OrderCommission();
            
            // 计算实际止损止盈额度
            if(OrderStopLoss() > 0)
            {
               double slAmount = 0;
               double priceDiff = 0;
               if(OrderType() == OP_BUY)
                  priceDiff = OrderOpenPrice() - OrderStopLoss();
               else if(OrderType() == OP_SELL)
                  priceDiff = OrderStopLoss() - OrderOpenPrice();
               
               slAmount = priceDiff * OrderLots() * MarketInfo(Symbol(), MODE_TICKVALUE) / MarketInfo(Symbol(), MODE_TICKSIZE);
               totalSLAmount += MathAbs(slAmount);
            }
            
            if(OrderTakeProfit() > 0)
            {
               double tpAmount = 0;
               double priceDiff = 0;
               if(OrderType() == OP_BUY)
                  priceDiff = OrderTakeProfit() - OrderOpenPrice();
               else if(OrderType() == OP_SELL)
                  priceDiff = OrderOpenPrice() - OrderTakeProfit();
               
               tpAmount = priceDiff * OrderLots() * MarketInfo(Symbol(), MODE_TICKVALUE) / MarketInfo(Symbol(), MODE_TICKSIZE);
               totalTPAmount += MathAbs(tpAmount);
            }
         }
      }
   }
   
   // 更新一键平仓按钮文本
   string closeButtonText = "一键平仓 | $" + DoubleToStr(totalProfit, 2);
   color buttonColor = (totalProfit >= 0) ? clrGreen : clrRed;
   ObjectSetString(0, Prefix + "CLOSE_ALL", OBJPROP_TEXT, closeButtonText);
   ObjectSetInteger(0, Prefix + "CLOSE_ALL", OBJPROP_BGCOLOR, buttonColor);
   
   // 更新实际止损止盈额度显示
   ObjectSetString(0, Prefix + "ACTUAL_SL", OBJPROP_TEXT, "实际止损: $" + DoubleToStr(totalSLAmount, 2));
   ObjectSetString(0, Prefix + "ACTUAL_TP", OBJPROP_TEXT, "实际止盈: $" + DoubleToStr(totalTPAmount, 2));
}

//+------------------------------------------------------------------+
//| 处理追踪止损                                                     |
//+------------------------------------------------------------------+
void ProcessTrailingStop()
{
   if(currentTrailing <= 0) return;
   
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         {
            RefreshRates();
            
            if(OrderType() == OP_BUY)
            {
               double newSL = Bid - currentTrailing * Point;
               if(newSL > OrderStopLoss() + TrailingStep * Point)
               {
                  bool result = OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue);
                  if(!result)
                  {
                     Print("追踪止损修改失败，错误代码: ", GetLastError());
                  }
               }
            }
            else if(OrderType() == OP_SELL)
            {
               double newSL = Ask + currentTrailing * Point;
               if(newSL < OrderStopLoss() - TrailingStep * Point || OrderStopLoss() == 0)
               {
                  bool result = OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrRed);
                  if(!result)
                  {
                     Print("追踪止损修改失败，错误代码: ", GetLastError());
                  }
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| 平仓反手                                                         |
//+------------------------------------------------------------------+
void CloseAndReverse()
{
   // 统计当前持仓情况
   int buyCount = 0, sellCount = 0;
   double totalBuyLots = 0, totalSellLots = 0;
   
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         {
            if(OrderType() == OP_BUY)
            {
               buyCount++;
               totalBuyLots += OrderLots();
            }
            else if(OrderType() == OP_SELL)
            {
               sellCount++;
               totalSellLots += OrderLots();
            }
         }
      }
   }
   
   // 先平仓所有订单
   CloseAllOrders();
   
   // 等待平仓完成
   Sleep(500);
   
   // 反手开仓
   RefreshRates();
   
   if(buyCount > 0 && totalBuyLots > 0)
   {
      // 原来有买单，现在开卖单
      double price = Bid;
      double sl = 0, tp = 0;
      
      if(currentSL > 0)
         sl = price + currentSL * Point;
      if(currentTP > 0)
         tp = price - currentTP * Point;
         
      int ticket = OrderSend(Symbol(), OP_SELL, totalBuyLots, price, 3, sl, tp, 
                            "平仓反手", Magic, 0, clrRed);
      if(ticket < 0)
      {
         Print("反手开仓失败，错误代码: ", GetLastError());
      }
   }
   
   if(sellCount > 0 && totalSellLots > 0)
   {
      // 原来有卖单，现在开买单
      double price = Ask;
      double sl = 0, tp = 0;
      
      if(currentSL > 0)
         sl = price - currentSL * Point;
      if(currentTP > 0)
         tp = price + currentTP * Point;
         
      int ticket = OrderSend(Symbol(), OP_BUY, totalSellLots, price, 3, sl, tp, 
                            "平仓反手", Magic, 0, clrBlue);
      if(ticket < 0)
      {
         Print("反手开仓失败，错误代码: ", GetLastError());
      }
   }
}

//+------------------------------------------------------------------+
//| 删除所有对象                                                     |
//+------------------------------------------------------------------+
void DeleteAllObjects()
{
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
   {
      string objName = ObjectName(i);
      if(StringFind(objName, Prefix) == 0)
      {
         ObjectDelete(0, objName);
      }
   }
   ChartRedraw();
}