library verilog;
use verylog.vl_types.all;
entity eyulingo_ios_dev is
    todo(
        - [ ] 快速进入／退出 CartPageView 闪退问题
        - [ ] 点击购物车项目不能进入商品详情问题
        - [ ] 点击表头不能进入商店详情问题
        - [ ] 在短时间内（一分钟）没有进行购物车更新的情况下不要重复加载
        - [ ] 下拉更新，包括搜索页面以及购物车页面，以及将来的已购商品页面
        - [ ] CI/CD
    );
    completed(
        - [x] 登录
        - [x] 注册
        - [x] 找回密码
        - [x] 更改邮箱绑定
        - [x] 搜索商品
        - [x] 加入购物车
        - [x] 删除购物车
        - [x] 更新头像
        - [x] 更新个人资料
        - [x] 修改密码
        - [x] 商品／商店详情
    )
end eyulingo_ios_dev;