// 変換json
var json;
// instagramの画像URLを保持するハッシュ
var instagramImgs = {};
// userID毎にセットする画像URLを保持するハッシュ
var userIdImgIdMap = {};

// readyイベント
$(document).ready(function(){
  // cookieからid-urlマップを取得
  getIdUrlMapFromCookie();

  // 先行して画像を変更
  changeImages();

  // 猫リセットボタンを配置する
  setChangeCatBtn();

  // テキストを猫語変換する
  chanegFeedTextToNayngo();

  // instagramAPIを実行して猫画像を取得 → 画像を変更する
  searchCatImageByInstagram();

  // InstagramAPI関連イベント
  $('.instagram').on('willLoadInstagram', function(event, options) {
  });

  $('.instagram').on('didLoadInstagram', function(event, response) {
    $.each(response.data, function (key, object){
      // hashに格納
      instagramImgs[object.id] = object.images.thumbnail.url;
    });
    // 画像を変換
    changeImages();
  });

  // リセットボタンクリックイベント
  $('.resetNyanImg').click(function(){
    object = $(this).parent().find('img.chatter-photo');
    userId = $(this).parent().find('a > span').attr('data-hovid');
    changeImage(object, userId);
  });
});

// instagramAPIを実行して猫画像を取得 → 画像を変更する
function searchCatImageByInstagram(){
  $(".instagram").instagram({
    hash: '猫',
    clientId: '2ada5b264ce849c8a22a4792911ee703'
  });
}

// cookieからid-urlマップを取得する
function getIdUrlMapFromCookie(){
  jsonStr = $.cookie('Catter')
  if(jsonStr){
    userIdImgIdMap = JSON.parse(jsonStr);
  }
}

// 猫リセットボタンを配置する
function setChangeCatBtn(){
  $('.chatter-photo').parent().parent().parent().append('<img width="16px" height="16px" src="/s.gif" alt="別のネコにする" class="resetNyanImg">');  
}

// フィードを猫語変換する
function chanegFeedTextToNayngo(){
  $.getJSON("/resource/catter_json" , function(data) {
    json = data;
    $('.feeditemtext, .feedcommenttext').each(function(){
      text = $(this).html();
      text = toNyango(text);
      $(this).html(text);
    });
  });
}

// テキストを猫語に変える
function toNyango(text){
  $.each(json, function(key, value){
    text = text.replace(new RegExp(key, 'g'), value);
  });
  return text;
}

// 画像を猫に変える
function changeImages(){
  $('.chatter-photo').each(function(key, object){
    // userIDを取得
    userId = $(object.parentElement).attr('data-hovid');
    var randImg;

    if(userId in userIdImgIdMap){
      // mapが存在する場合
      $(this).attr("src", userIdImgIdMap[userId]);

    }else if ($.isEmptyObject(instagramImgs)){
      // まだinstagramから検索が完了していない場合はloadingに
      $(this).attr("src", "/resource/Loading");
    }else{
      // mapに存在しない場合、randamに配列から取得
      changeImage(this, userId);
    }
  });
}

// 画像を変更する(強制変更)
function changeImage(object, userId){
  var keys = Object.keys(instagramImgs);
  randImg = instagramImgs[keys[Math.floor(keys.length * Math.random())]];

  // id-img mapにセット
  userIdImgIdMap[userId] = randImg;

  // cookieにセット
  $.cookie("Catter", JSON.stringify(userIdImgIdMap), { expires: 365});

  // 画像を変更
  $(object).attr("src", randImg);
}