// FairWing Script
// Written by いっちゃん

string AnimData_1 = "Bento_head_wink";
string AnimData_2 = "Head_kuchipaku_01";

string currentAnim = "";
key owner;
float gap = 0.5;

integer ch_randaddval = 3; // HEAD
integer listener;
integer head_channel;
integer body_channel;
integer hud_channel;
string channel_name = "";

integer genCh()
{
    integer gen;

    string str_1 = llGetSubString((string)llGetOwner(),0,3);
    string str_2 = llGetSubString((string)llGetCreator(),0,3);
    gen = -1-(integer)("0x"+str_1)-(integer)("0x"+str_2) + ch_randaddval;

    return gen;
}

startAnimation(string anim)
{
    if(currentAnim == anim) return;
    
    stopAnimation();
    
    currentAnim = anim;
    
    if( currentAnim != "")
    {
        llStartAnimation(currentAnim);
    }
}

stopAnimation()
{
    if(currentAnim != "")
    {
        llStopAnimation(currentAnim);
        currentAnim = "";
    }
}

default
{
    state_entry()
    {
        owner = llGetOwner();
        currentAnim = "";
        
        head_channel = genCh();
        body_channel = head_channel - 1;
        hud_channel = body_channel - 1;
        listener = llListen(head_channel,channel_name,"","");
    }
    
    attach(key agent)
    {
        if ( agent != NULL_KEY )
        {
            owner = agent;
            llRequestPermissions(owner, PERMISSION_TRIGGER_ANIMATION);
            startAnimation(currentAnim);
            llSetTimerEvent(gap);

            llListenRemove(listener);
            head_channel = genCh();
            body_channel = head_channel - 1;
            hud_channel = body_channel - 1;
            listener = llListen(head_channel, channel_name, "","");
            llSay(body_channel, "<BMS_HEAD_ADD>");
            llSay(hud_channel, "<BMS_HEAD_ADD>");
        }
        else
        {
            llSay(body_channel, "<BMS_HEAD_REMOVE>");
            llSay(hud_channel, "<BMS_HEAD_REMOVE>");

            stopAnimation();
            llSetTimerEvent(0); // timer 停止
        }
    }
    
    listen(integer ch, string name, key id, string message)
    {
        if(ch == head_channel && llSubStringIndex(name,"[BMS]") != -1)
        {
            if(message == "<BMS_HEAD_CHECK>")
            {
                llSay(body_channel, "<BMS_HEAD_ADD>");
                llSay(hud_channel, "<BMS_HEAD_ADD>");                
            }
        }
    }
    
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TRIGGER_ANIMATION)
        {
            startAnimation(currentAnim);
        }
    }

    timer()
    {
        /*
        AGENT_ALWAYS_RUN    // 走行モード("常に走る") になっている、もしくは tap-tap-hold を使っている 
        AGENT_ATTACHMENTS   // 装着している 
        AGENT_AUTOPILOT     // is in "オートパイロット" モード 
        AGENT_AWAY          // "away" モード 
        AGENT_BUSY          // "busy" モード 
        AGENT_CROUCHING     // しゃがんでいる 
        AGENT_FLYING        // 飛んでいる 
        AGENT_IN_AIR        // 空中に浮かんでいる 
        AGENT_MOUSELOOK     // マウスルック 
        AGENT_ON_OBJECT     // オブジェクトに座っている 
        AGENT_SCRIPTED      // スクリプトを装着 
        AGENT_SITTING       // 座っている 
        AGENT_TYPING        // 入力している 
        AGENT_WALKING       // 歩いている、走っている、しゃがみ歩きをしている 
        */
        
        integer info = llGetAgentInfo(owner);

        if( info & AGENT_TYPING )
        {
            startAnimation(AnimData_2);
        }
        else if( info & AGENT_ATTACHMENTS )
        {
            startAnimation(AnimData_1);
        }
        else
        {
            stopAnimation();
        }
    }
}
