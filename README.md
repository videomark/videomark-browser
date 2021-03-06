# VideoMark Browser (Custom Android Chromium patches)
本リポジトリには Android 版 Chromium を Web VideoMark プロジェクト用にカスタマイズした VideoMark Browser をビルドする為の Chromium に対するパッチファイルを収めています。

* 対応する Chromium バージョンは現在 81.0.4044.138 です。
* chromium のソースコードリポジトリ
  * https://chromium.googlesource.com/chromium/src/  
* リポジトリをダウンロード (fetch --nohooks android) したら、対応する Chromium バージョンのタグをチェックアウトしてパッチを適用し、ビルドしてください。
  * ビルド手順  
  https://chromium.googlesource.com/chromium/src/+/master/docs/android_build_instructions.md
  * タグ指定手順  
  https://www.chromium.org/developers/how-tos/get-the-code/working-with-release-branches
  * タグ一覧  
  https://chromium.googlesource.com/chromium/src/+refs

# ライセンス
本リポジトリのコードは原則としてパッチを適用する対象の各ファイルと同一のライセンスを付与します。
個別のパッチファイルなどで特に記載がない場合は Chromium プロジェクトのデフォルトライセンスと同一の、修正 BSD ライセンスとなります。

# パッチファイルの解説
### sodium_whitelist.diff
動画再生品質の記録にあたり、以下の機能の実行を許可するドメインを判別するホワイトリストです。
- sodium.js の挿入
- ```window.sodium```オブジェクトへのアクセス
- Resource Timing API へのアクセスの強制許可

PC 版サイトの表示を強制する上記とは別のホワイトリストもこのパッチに含まれます。

### sodium_pref.diff
動画再生時の視聴情報を収集し、推定体感品質値を計算して確認できるようにする機能を on/off できる設定管理と、測定に関する一時的な情報をタブごとに保持するコードです。プロファイルの pref に設定を保存し、読み込んでウェブページに反映させます。  
blink モジュールから content、chrome モジュールまで、renderer 領域から browser 領域にまでまたがる基礎的な部分の変更となる大規模なパッチです。  
chromium における pref の読み込みの動作として、pref の値が必要な時に都度読み込むようなことはせず、タブ生成時に pref から読み込んだ値をコピーして渡すという動作のため、プロファイルへのアクセスにもかかわらず IPC していませんが、pref 変更時は必要に応じてタブに同期させるという動作に注意が必要です。  
タブごとの一時的な情報は```window.sodium```オブジェクトを介して、ブラウザーのメニューに状態を表示する用途になるため、IPC を通して各レイヤーに最新の情報を提供します。

### sodium_pref_ui.diff
上記の動画再生時の視聴情報を収集する機能の on/off を切り替える設定画面周りの変更です。  
メニューの設定ページの詳細設定に、「動画再生品質の記録」の項目が追加され、該当項目のページで動画再生品質の記録の on/off 操作と説明が表示されます。  
on/off 操作によるウェブページの自動再読み込みには対応しておらず、手動でウェブページを再読み込みすることで設定が反映されます。  
また、メニューに「計測中に結果を表示」の項目が追加されます。QoE やビットレートなどの計測結果の表示の on/off の切り替えができます。

### sodium_result.diff
収集した動画再生時の視聴情報を確認する機能です。  
メニューに「動画の視聴結果を確認」の項目が追加され、タップすると収集した動画再生時の視聴情報を確認するページが表示されます。  
確認ページはブラウザーの内部 URL として実装されてますが、サーバーに QoE 値を問い合わせる動作があるためオンラインである必要があります。  
また、メニューに「VideoMark の設定」の項目も追加されます。VideoMark に関する詳細な設定画面を新しいタブで開きます。

### sodium_object.diff
動画再生時の視聴情報収集が on かつ許可ドメインのウェブページ上で```window.sodium```オブジェクトを提供します。
- window.sodium.userAgent  
PC 版サイト表示だと```window.navigator.userAgent```は PC のものに切り替わりますが、```window.sodium.userAgent```は設定によって上書きされてない端末由来のユーザーエージェントを常に返します。
- window.sodium.locationIp  
表示ページの IP アドレスを取得します。
- window.sodium.currentTab  
測定に関する一時的な情報を設定または取得します。
  - alive  
    動画が再生中かどうかを表す bool 値です。
  - displayOnPlayer  
    計測中に結果を表示するかどうかを表す bool 値です。
- window.sodium.storage  
[chrome.storage](https://developer.chrome.com/extensions/storage) に準じた機能を提供します。
  - local のみです。sync、managed はありません。
  - 容量制限はありません。getBytesInUse()、QUOTA_BYTES などのプロパティもありません。
  - onChanged イベントはありません。
  - chrome.storage とは違って、ウェブページのコンテンツとして動作します。
  - キーは文字列として、値は V8 オブジェクトをシリアライズしたバイト列として保存されます。

動画再生時の視聴情報収集が off または許可ドメイン以外の場合は、```window.sodium```は null になります。  

### sodium_storage.diff
window.sodium.storageを介してデータを保存します。保存形式については以下のようになります。
- データはプロファイルフォルダの```sodium_storage_local```に、LevelDB 形式で保存されます。
- 圧縮は LevelDB により自動的に行われるため、事前事後の特別な処理は不要です。
- [Mojo](https://chromium.googlesource.com/chromium/src/+/master/mojo/README.md) による IPC がアクセスのたびに行われます。

### timing_allow_origin.diff
動画再生時の視聴情報収集が on かつ許可ドメインのウェブページ上で [Resource Timing API](https://developer.mozilla.org/en-US/docs/Web/API/Resource_Timing_API) によるパフォーマンスデータの取得を強制的に許可します。

### netinfo_apn_plmn.diff
[NetworkInformation API](https://developer.mozilla.org/ja/docs/Web/API/NetworkInformation) を拡張し、動画再生時の視聴情報収集が on かつ許可ドメインのウェブページ上で APN と PLMN が取得可能なプロパティを追加します。

### inject_sodium.diff
動画再生時の視聴情報収集が on かつ許可ドメインのウェブページ上で sodium.js を実行するための script タグを body の末尾に挿入します。

### force_desktop_mode.diff
動画再生時の視聴情報収集が on かつ該当ドメインの場合、表示モードを PC 版サイトに強制します。  
m.youtube.com を開いたときに Android アプリ版の YouTube を開かず、ブラウザーで表示する機能も含まれます。
