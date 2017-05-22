integer ch_randaddval = 1;
integer listener = 0;
integer hud_channel = 0;
integer body_channel = 0;
string channel_name = "[BMS] BMSG_Body_take16";

key kPartsQuery;
integer iPartsLine = 0;
string notecard_parts_name = "CLOTH_PARTS";
key notecard_parts_key = NULL_KEY;

list cloth_parts_list = [];

integer genCh()
{
    integer gen;

    string str_1 = llGetSubString((string)llGetOwner(),0,3);
    string str_2 = llGetSubString((string)llGetCreator(),0,3);
    gen = -1-(integer)("0x"+str_1)-(integer)("0x"+str_2) + ch_randaddval;

    return gen;
}

// 文字列置換
string strReplace(string str, string search, string replace)
{
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}

restart_start_message()
{
    llOwnerSay((string)((float)llGetFreeMemory()/1000.0) + " KB free");
    llOwnerSay("\n---- ALL Reset Start ----\n Please, wait some mins.");
}
restart_end_message()
{
    llOwnerSay("\n---- Reset Complete ----\n Thank you for waiting :)");
    llOwnerSay((string)((float)llGetFreeMemory()/1000.0) + " KB free");
}
waiting_message()
{
    llOwnerSay(".......");
}

// ノートカード読み込み処理
config_init()
{ 
    /*----------------------*/
    /* CLOTH_PARTS 読み込み */
    key nc_key_2 = llGetInventoryKey(notecard_parts_name);
    if (nc_key_2 == notecard_parts_key)
    {
        // 設定ノートカード以外の、他のアイテムが変更されました。
        return; // この場合、ノートカードの読み込みをスキップします。
    }
    // 新しいノートカードのキーを覚えます。
    notecard_parts_key = nc_key_2;
    kPartsQuery = llGetNotecardLine(notecard_parts_name, iPartsLine);
}

cloth_enable_fromlist(list parts_list, integer flag)
{
    integer i = 0;
    for(i = 0 ; i < llGetListLength(parts_list) ; i++)
    {
        string parts = llList2String(parts_list, i);
        integer idx = llListFindList(cloth_parts_list, [parts]);
        
        if(idx != -1)
        {    
            list pos = llParseString2List(llList2String(cloth_parts_list,idx+1), [","],[""]);
            integer link = llList2Integer(pos,0);
            integer face = llList2Integer(pos,1);
            
            if(link != -1)
            {
                if(flag == TRUE)
                {
                    llSetLinkAlpha(link, 1.0, face);
                }
                else
                {
                    llSetLinkAlpha(link, 0.0, face);
                }
            }
            pos = [];
        }
    }    
}

cloth_enable(string str)
{
    list info = llParseString2List(str, ["$"], [""]);

    integer idx = llListFindList(cloth_parts_list, [llList2String(info,0)]);
    if(idx != -1)
    {
        //list parts_list = llParseString2List(llList2String(cloth_parts_list, idx+1),["&"],[""]);
        
        //integer i;
        //for(i = 0 ; i < llGetListLength(parts_list) ; i++)
        //{
            //list pos_list = llParseString2List(llList2String(parts_list, i),[","],[""]);
            
            list pos_list = llParseString2List(llList2String(cloth_parts_list, idx+1),[","],[""]);
            
            integer link = llList2Integer(pos_list,0);
            integer face = llList2Integer(pos_list,1);
            
            float alpha = llList2Float(info,1);
            
            llSetLinkAlpha(link, alpha, face);
            
            pos_list = [];
        //}
        
        //parts_list = [];
    }
    info = [];
}

default
{
    state_entry()
    {
        hud_channel = genCh();
        listener = llListen(hud_channel, channel_name, "","");
        body_channel = hud_channel + 1;
        
        restart_start_message();
        
        // 起動時にノートカードを一通り読み込みます。
        config_init();
    }
    
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)         
        {
            // インベントリが変更になったらノートカードを読み込みます。
            llResetScript();
            //config_init();
        }
    }

    dataserver(key query_id, string data)
    {
        if(query_id == kPartsQuery)
        {
            // ノートカードの 1 行です。
            if (data == EOF) 
            {
                llOwnerSay("Finished reading [" + notecard_parts_name + "] configuration.");
                restart_end_message();                
            } 
            else
            {
                data = strReplace(data, " ", "");
                data = strReplace(data, "\n", "");
                if(llSubStringIndex(data,"#") != -1)
                {
                    // # なら読み飛ばし
                    jump read_out;
                }
                
                if(data != "")
                {
                    list info = llParseString2List(data, ["="], [""]);
                    
                    cloth_parts_list += llList2String(info, 0);
                    cloth_parts_list += llList2String(info, 1);
                    
                    info = [];
                    
                    waiting_message();
                }
                
                @read_out;
                
                // カウンタをインクリメントします。
                ++iPartsLine;
                //ノートカードの次の行をリクエストします。
                kPartsQuery = llGetNotecardLine(notecard_parts_name, iPartsLine);
            }
        }
    }
    
    attach(key id)
    {
        if(listener != 0)
        {
            llListenRemove(listener);
            hud_channel = genCh();
            body_channel = hud_channel + 1;
            listener = llListen(hud_channel, channel_name, "","");
        }
    }
    
    listen(integer ch, string name, key id, string message)
    {
        if(ch == hud_channel && name == channel_name)
        {
            // Mesh Body からのメッセージなら
            if(llSubStringIndex(message,":") != -1)
            {
                list info_list = llParseString2List(message, ["{",":"], [""]);
                list parts_list = llParseString2List(strReplace(llList2String(info_list,1),"}",""),["&"],[""]);
                integer flag = llList2Integer(info_list,2);
    
                cloth_enable_fromlist(parts_list, flag);
                
                info_list = [];
                parts_list = [];                
            }
            else if(llSubStringIndex(message,"$") != -1)
            {
                cloth_enable(message);
            }
        }
    }

}
