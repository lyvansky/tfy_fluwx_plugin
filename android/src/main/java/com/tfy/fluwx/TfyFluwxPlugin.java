package com.tfy.fluwx;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import com.tencent.mm.opensdk.modelpay.PayReq;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.tfy.fluwx.wxapi.StateManager;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** TfyFluwxPlugin */
public class TfyFluwxPlugin implements MethodCallHandler {

  private static final String TAG = "FluwxPlugin-->";
  public static final String filterName = "wxCallback";
  private IWXAPI wxApi;
  private Registrar registrar;
  private static Result result;
  private static final int THUMB_SIZE = 150;


  //微信支付回调
  private static BroadcastReceiver wxpayCallbackReceiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      Integer errCode = intent.getIntExtra("errCode", -3);
      Log.e(TAG, errCode.toString());
      result.success(errCode);
    }
  };

  private TfyFluwxPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {

    final MethodChannel channel = new MethodChannel(registrar.messenger(), "com.tfy/fluwx");
    final TfyFluwxPlugin plugin = new TfyFluwxPlugin(registrar);
    channel.setMethodCallHandler(plugin);
    registrar.context().registerReceiver(wxpayCallbackReceiver, new IntentFilter(filterName));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    TfyFluwxPlugin.result = result;
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "register":
        this.registerToWX(call, result);
        break;
      case "pay":
        this.pay(call);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  //注册微信app id
  private void registerToWX(MethodCall call, Result result) {
    String appId = call.argument("appId");
    wxApi = WXAPIFactory.createWXAPI(registrar.context(), appId);
    boolean res = wxApi.registerApp(appId);
    StateManager.setApi(wxApi);
    result.success(res);
  }


  //调起微信支付
  private void pay(MethodCall call) {
    PayReq req = new PayReq();
    req.appId = call.argument("appid");
    req.partnerId = call.argument("partnerid");
    req.prepayId = call.argument("prepayid");
    req.packageValue = call.argument("package");
    req.nonceStr = call.argument("noncestr");
    req.timeStamp = call.argument("timestamp");
    req.sign = call.argument("sign");
    wxApi.sendReq(req);
  }

}
