(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["chunk-2d8c2f14"],{"129f":function(e,n){e.exports=Object.is||function(e,n){return e===n?0!==e||1/e===1/n:e!=e&&n!=n}},"1ffa":function(e,n,t){"use strict";var o=/^[-!#$%&'*+\/0-9=?A-Z^_a-z{|}~](\.?[-!#$%&'*+\/0-9=?A-Z^_a-z`{|}~])*@[a-zA-Z0-9](-*\.?[a-zA-Z0-9])*\.[a-zA-Z](-?[a-zA-Z0-9])+$/;n.validate=function(e){if(!e)return!1;if(e.length>254)return!1;var n=o.test(e);if(!n)return!1;var t=e.split("@");if(t[0].length>64)return!1;var i=t[1].split(".");return!i.some((function(e){return e.length>63}))}},"466d":function(e,n,t){"use strict";var o=t("d784"),i=t("825a"),a=t("50c4"),r=t("1d80"),s=t("8aa5"),l=t("14c3");o("match",1,(function(e,n,t){return[function(n){var t=r(this),o=void 0==n?void 0:n[e];return void 0!==o?o.call(n,t):new RegExp(n)[e](String(t))},function(e){var o=t(n,e,this);if(o.done)return o.value;var r=i(e),c=String(this);if(!r.global)return l(r,c);var u=r.unicode;r.lastIndex=0;var d,m=[],g=0;while(null!==(d=l(r,c))){var f=String(d[0]);m[g]=f,""===f&&(r.lastIndex=s(c,a(r.lastIndex),u)),g++}return 0===g?null:m}]}))},"841c":function(e,n,t){"use strict";var o=t("d784"),i=t("825a"),a=t("1d80"),r=t("129f"),s=t("14c3");o("search",1,(function(e,n,t){return[function(n){var t=a(this),o=void 0==n?void 0:n[e];return void 0!==o?o.call(n,t):new RegExp(n)[e](String(t))},function(e){var o=t(n,e,this);if(o.done)return o.value;var a=i(e),l=String(this),c=a.lastIndex;r(c,0)||(a.lastIndex=0);var u=s(a,l);return r(a.lastIndex,c)||(a.lastIndex=c),null===u?-1:u.index}]}))},"9ed6":function(e,n,t){"use strict";t.r(n);var o=function(){var e=this,n=e.$createElement,o=e._self._c||n;return o("div",{directives:[{name:"loading",rawName:"v-loading",value:e.pageLoading,expression:"pageLoading"}],staticClass:"login-container"},[o("div",{staticClass:"log-main-form"},[o("el-form",{ref:"loginForm",staticClass:"login-form",attrs:{model:e.loginForm,"auto-complete":"on","label-position":"left"}},[o("div",{staticClass:"login-main-head text-center mb-6"},[o("img",{staticClass:"login-logo",attrs:{src:t("53a2"),alt:"logo"}}),o("h3",{staticClass:"title mb-0"},[e._v("Cloud 3D Print "),o("br"),e._v(" Control panel login")])]),o("el-form-item",{attrs:{prop:"username",label:"Email"}},[o("span",{staticClass:"svg-container"},[o("i",{staticClass:"cp cp-email font-size-18"})]),o("el-input",{ref:"email",attrs:{placeholder:"Email",name:"email",type:"text",tabindex:"1","auto-complete":"on"},on:{input:e.onChangeVerifyEmail},model:{value:e.loginForm.email,callback:function(n){e.$set(e.loginForm,"email",n)},expression:"loginForm.email"}})],1),e.isCodeSend?o("div",[o("p",{staticClass:"mb-5 text-gray9 font-size-12"},[e._v("We just sent you a temporary sign up code. Please check your inbox and paste the sign up code below.")]),o("el-form-item",{attrs:{prop:"password",label:"Login code"}},[o("span",{staticClass:"svg-container"},[o("i",{staticClass:"cp cp-code font-size-18"})]),o("el-input",{ref:"code",attrs:{placeholder:"Code",name:"code",tabindex:"2","auto-complete":"on"},nativeOn:{keyup:function(n){return!n.type.indexOf("key")&&e._k(n.keyCode,"enter",13,n.key,"Enter")?null:e.handleLogin(n)}},model:{value:e.loginForm.code,callback:function(n){e.$set(e.loginForm,"code",n)},expression:"loginForm.code"}}),e.codeShow?o("el-link",{staticClass:"resend-btn",attrs:{type:"primary"},on:{click:e.onSendCode}},[e._v("Resend")]):o("el-link",{staticClass:"resend-btn"},[e._v(e._s(e.codeCount)+" s")])],1)],1):e._e(),e.isCodeSend?o("el-button",{staticClass:"login-btn mt-5",attrs:{loading:e.loading,type:"primary"},nativeOn:{click:function(n){return n.preventDefault(),e.handleLogin(n)}}},[e._v("Login")]):o("el-button",{staticClass:"login-btn mt-5",attrs:{loading:e.loading,disabled:!e.verifyEmail,type:"primary"},nativeOn:{click:function(n){return n.preventDefault(),e.onSendEmail(n)}}},[e._v("Continue with email")])],1)],1)])},i=[],a=(t("d3b7"),t("4d63"),t("ac1f"),t("25f0"),t("466d"),t("841c"),t("1ffa")),r=t.n(a),s=t("5f87"),l=t("aa98"),c=t("e3e1"),u={name:"Login",data:function(){return{loginForm:{email:"",code:""},verifyEmail:!1,isCodeSend:!1,codeTimer:null,codeCount:60,codeShow:!1,loginInfo:null,cloudTimer:null,cloudNumber:0,pageLoading:!1,loading:!1,passwordType:"password",redirect:void 0,deviceUUID:null}},watch:{$route:{handler:function(e){this.redirect=e.query&&e.query.redirect,"cloud"===e.query.location?(this.pageLoading=!0,this.onCloudTimer()):this.pageLoading=!1},immediate:!0}},beforeDestroy:function(){clearInterval(this.codeTimer)},mounted:function(){Object(s["g"])(!0)},methods:{onSendCode:function(){var e=this,n=60;this.codeShow&&Object(c["l"])(this.loginForm.email).then((function(n){e.$message.closeAll(),"success"===n.data.status?e.$message({message:"Please note that the email has been sent successfully!",type:"success"}):e.$message({message:"Mail delivery failed for unknown reason.",type:"error"})})),this.codeTimer||(this.codeCount=n,this.codeShow=!1,this.codeTimer=setInterval((function(){e.codeCount>0&&e.codeCount<=n?e.codeCount--:(e.codeShow=!0,clearInterval(e.codeTimer),e.codeTimer=null)}),1e3))},onChangeVerifyEmail:function(){var e=/^[0-9a-zA-Z][a-zA-Z0-9\._-]{1,}@[a-zA-Z0-9-]{1,}[a-zA-Z0-9](\.[a-z]{1,})+$/;this.verifyEmail=e.test(this.loginForm.email)},onSendEmail:function(){var e=this;this.loading=!0,Object(c["l"])(this.loginForm.email).then((function(n){console.log(n),e.isCodeSend=!0})).finally((function(){e.loading=!1,e.onSendCode()}))},onCloudTimer:function(){var e=this;null!=e.cloudTimer&&clearInterval(e.cloudTimer),e.cloudTimer=setInterval((function(){e.cloudLogin()}),1e3)},cloudLogin:function(){var e=this,n=this;n.cloudNumber++,10===n.cloudNumber&&(n.$message({message:"Login failed please enter your account password.",type:"error"}),clearInterval(n.cloudTimer),n.$router.push("/login")),Object(s["c"])()&&(clearInterval(n.cloudTimer),n.$store.commit("user/SET_TOKEN",Object(s["c"])()),n.$store.commit("user/SET_NAME",Object(s["a"])()),n.$store.commit("user/SET_USER_INFO",Object(s["d"])()),Object(l["g"])().then((function(t){n.deviceUUID=t.deviceUUID,Object(c["h"])(n.deviceUUID).then((function(t){console.log(t.status),"User is a member of the group the device belongs to."!==t.status&&"Device does not belong to any group."!==t.status||n.$router.push({path:e.redirect||"/"})})).catch((function(){n.$router.push("/login"),n.$message({message:"You don't have permision to access the device.",type:"error"})}))})))},getQueryString:function(e){var n=new RegExp("(^|&)"+e+"=([^&]*)(&|$)","i"),t=window.location.search.substr(1).match(n);return null!=t?unescape(t[2]):null},handleLogin:function(){var e=this,n=this;if(""===n.loginForm.username||""===n.loginForm.password)return n.$message.closeAll(),n.$message.error("Please enter your username and password"),!1;r.a.validate(this.loginForm.username)&&(this.loginForm.email=this.loginForm.username,delete this.loginForm.username),this.$refs.loginForm.validate((function(n){if(!n)return e.$message({message:"Invalid email/username or password.",type:"error"}),!1;e.loading=!0,e.$store.dispatch("user/login",e.loginForm).then((function(){console.log(e.redirect),e.$router.push({path:e.redirect||"/"}),e.loading=!1})).catch((function(){e.loading=!1,e.$message({message:"Invalid email/username or password.",type:"error"})}))}))}}},d=u,m=t("2877"),g=Object(m["a"])(d,o,i,!1,null,null,null);n["default"]=g.exports}}]);