package com.example.mobbb_ads;

import android.os.Bundle;
import android.widget.LinearLayout;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.interstitial.InterstitialAd;
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;
import com.google.android.gms.ads.LoadAdError;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.mobbb_ads/ad";
    private AdView mAdView;
    private RewardedAd rewardedAd;
    private InterstitialAd interstitialAd;
    private LinearLayout layout;
    private AdRequest adRequest;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Initialize Mobile Ads SDK
        MobileAds.initialize(this);

        // Create AdView for banner
        mAdView = new AdView(this);
        mAdView.setAdSize(AdSize.BANNER);
        mAdView.setAdUnitId("ca-app-pub-1749234779655108/4175989704"); // Replace with your Ad Unit ID
//        mAdView.setAdUnitId("ca-app-pub-9687530652502444/4022392139");
        // Create layout for banner
        layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.addView(mAdView);

        // Add the layout to the content view
        addContentView(layout, new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
        ));

        // Load Banner Ad
//        loadBannerAd();

        // Load Rewarded Ad
        loadRewardedAd();
    }

    // Handle pause lifecycle
    @Override
    protected void onPause() {
        super.onPause();
        if (mAdView != null) {
            mAdView.pause();
        }
    }

    // Handle resume lifecycle
    @Override
    protected void onResume() {
        super.onResume();
        if (mAdView != null) {
            mAdView.resume();
        }
    }

    // Handle destroy lifecycle
    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mAdView != null) {
            mAdView.destroy();
        }
    }

//    @Override
//    public void onBackPressed() {
//        // Hentikan iklan yang sedang berjalan
//        if (rewardedAd != null) {
//            rewardedAd = null; // Hapus referensi RewardedAd
//        }
//        if (interstitialAd != null) {
//            interstitialAd = null; // Hapus referensi InterstitialAd
//        }
//        super.onBackPressed();
//    }

    private void loadBannerAd() {
        if (mAdView == null) {
            System.out.println("Banner AdView is null. Skipping load.");
            return;
        }

        adRequest = new AdRequest.Builder().build();
        mAdView.setAdListener(new com.google.android.gms.ads.AdListener() {
            @Override
            public void onAdLoaded() {
                super.onAdLoaded();
                System.out.println("Banner Ad loaded successfully.");
            }

            @Override
            public void onAdFailedToLoad(LoadAdError adError) {
                super.onAdFailedToLoad(adError);
                System.out.println("Failed to load Banner Ad: " + adError.getMessage());
            }

            @Override
            public void onAdOpened() {
                super.onAdOpened();
                System.out.println("Banner Ad opened.");
            }

            @Override
            public void onAdClosed() {
                super.onAdClosed();
                System.out.println("Banner Ad closed.");
            }
        });

//        mAdView.loadAd(adRequest);
    }

    private void showBannerAd() {
        if (mAdView != null) {
            loadBannerAd();
//            result.success("Banner Ad loaded");
        } else {
//            result.error("AdError", "Banner AdView is not initialized", null);
        }
    }


    // Load Rewarded Ad
    private void loadRewardedAd() {
        adRequest = new AdRequest.Builder().build();
        RewardedAd.load(this, "ca-app-pub-1749234779655108/8658160193", adRequest,
//        RewardedAd.load(this, "ca-app-pub-9687530652502444/3798999034", adRequest,
                new RewardedAdLoadCallback() {
                    @Override
                    public void onAdLoaded(RewardedAd rewardedAd) {
                        MainActivity.this.rewardedAd = rewardedAd;

                        // Tambahkan callback untuk menangani ketika iklan selesai
                        MainActivity.this.rewardedAd.setFullScreenContentCallback(new FullScreenContentCallback() {
                            @Override
                            public void onAdShowedFullScreenContent() {
                                // Iklan mulai ditampilkan
                                System.out.println("Rewarded Ad started.");
                            }

                            @Override
                            public void onAdDismissedFullScreenContent() {
                                // Iklan selesai dilihat atau ditutup
                                System.out.println("Rewarded Ad finished or dismissed.");
                                MainActivity.this.rewardedAd = null; // Hapus referensi ke iklan
                                try {
                                    loadRewardedAd();
                                }
                                catch(Exception e) {
                                    loadRewardedAd();
                                }
                                // Muat ulang rewarded ad secara otomatis
                            }

                            @Override
                            public void onAdFailedToShowFullScreenContent(AdError adError) {
                                // Gagal menampilkan iklan
                                System.out.println("Failed to show Rewarded Ad: " + adError.getMessage());
                                MainActivity.this.rewardedAd = null; // Hapus referensi ke iklan
                                try {
                                    loadRewardedAd();
                                }
                                catch(Exception e) {
                                    loadRewardedAd();
                                }
                            }
                        });
                    }

                    @Override
                    public void onAdFailedToLoad(LoadAdError loadAdError) {
                        // Gagal memuat iklan
                        System.out.println("Failed to load Rewarded Ad: " + loadAdError.getMessage());
                        rewardedAd = null;
                    }
                });
    }

    // Show Rewarded Ad
    private void showRewardedAd() {
        if (rewardedAd != null) {
            rewardedAd.show(this, rewardItem -> {
                // Handle the reward here
                System.out.println("User earned the reward: " +
                        rewardItem.getAmount() + " " + rewardItem.getType());
            });
        } else {
            System.out.println("Rewarded Ad not available. Loading a new one...");
            loadRewardedAd(); // Pastikan memuat iklan jika belum tersedia
        }
    }

    // Load Interstitial Ad
    private void loadInterstitialAd() {
        InterstitialAd.load(this, "ca-app-pub-9687530652502444/6672574386", adRequest,
//        InterstitialAd.load(this, "ca-app-pub-6940734118750824/1646777713", adRequest,
                new InterstitialAdLoadCallback() {
                    @Override
                    public void onAdLoaded(InterstitialAd interstitialAd) {
                        MainActivity.this.interstitialAd = interstitialAd;

                        // Tambahkan callback untuk menangani peristiwa iklan
                        MainActivity.this.interstitialAd.setFullScreenContentCallback(new FullScreenContentCallback() {
                            @Override
                            public void onAdShowedFullScreenContent() {
                                // Iklan mulai ditampilkan
                                System.out.println("Interstitial Ad started.");
                            }

                            @Override
                            public void onAdDismissedFullScreenContent() {
                                // Iklan selesai ditampilkan atau ditutup
                                System.out.println("Interstitial Ad finished or dismissed.");
                                MainActivity.this.interstitialAd = null; // Hapus referensi ke iklan
                                try {
                                    loadInterstitialAd();
                                }
                                catch(Exception e) {
                                    loadInterstitialAd();
                                }
                                // Muat ulang interstitial ad
                            }

                            @Override
                            public void onAdFailedToShowFullScreenContent(AdError adError) {
                                // Gagal menampilkan iklan
                                System.out.println("Failed to show Interstitial Ad: " + adError.getMessage());
                                MainActivity.this.interstitialAd = null; // Hapus referensi ke iklan
                                try {
                                    loadInterstitialAd();
                                }
                                catch(Exception e) {
                                    loadInterstitialAd();
                                }
                            }
                        });
                    }

                    @Override
                    public void onAdFailedToLoad(LoadAdError loadAdError) {
                        // Gagal memuat iklan
                        System.out.println("Failed to load Interstitial Ad: " + loadAdError.getMessage());
                        MainActivity.this.interstitialAd = null;
                    }
                });
    }

    // Show Interstitial Ad
    private void showInterstitialAd() {
        if (interstitialAd != null) {
            interstitialAd.show(this);
        } else {
            System.out.println("Interstitial Ad not available. Loading a new one...");
            loadInterstitialAd(); // Muat ulang iklan jika belum tersedia
        }
    }

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("showAd")) {
                        mAdView.loadAd(adRequest);
                        showRewardedAd();
//                        showInterstitialAd();
                        result.success(null);
                    } else {
                        result.notImplemented();
                    }
                });
    }
}
