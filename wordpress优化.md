在 apache服务器里，安装 WordPress 5.4 中文版本，使用二零二零主题时，实测很有效。
有一个不确定的点，是否debian里，用apache会比nginx快？

一共有四个有效的方法。
- 首先，安装中文版本的 wordpress 。
- 其次，不要开启SSL。以https打开主页会慢很多。
- 第三个是安装插件Autoptimize。 
- 最后，是修改functions.php文件。

安装插件能压缩css、html和js文件，还能将css合并到html文件中，减少请求数。安装完插件后，能明显感受到速度提升。
当然，利用插件压缩文件并不会带来本质上的速度改观。

最为重要的方法，仍是精简wordpress内置的一些不常用功能。

下面是在网络上收集的一些代码，并且实测有效。将下面代码复制到“主题编辑器”里的functions.php文件最后面。

```
    //屏蔽 REST API
    add_filter(‘json_enabled’, ‘__return_false’ );
    add_filter(‘json_jsonp_enabled’, ‘__return_false’ );
    add_filter(‘rest_enabled’, ‘__return_false’);
    add_filter(‘rest_jsonp_enabled’, ‘__return_false’);
```

```
    // 移除头部 wp-json 标签和 HTTP header 中的 link
    remove_action(‘wp_head’, ‘rest_output_link_wp_head’, 10 );
    remove_action(‘template_redirect’, ‘rest_output_link_header’, 11 );
``` 

```
    // 移除 Emoji 脚本
    remove_action( ‘admin_print_scripts’, ‘print_emoji_detection_script’);
    remove_action( ‘admin_print_styles’, ‘print_emoji_styles’);
    remove_action( ‘wp_head’, ‘print_emoji_detection_script’, 7);
    remove_action( ‘wp_print_styles’, ‘print_emoji_styles’);
    remove_filter( ‘the_content_feed’, ‘wp_staticize_emoji’);
    remove_filter( ‘comment_text_rss’, ‘wp_staticize_emoji’);
    remove_filter( ‘wp_mail’, ‘wp_staticize_emoji_for_email’);
    add_filter( ’emoji_svg_url’, ‘__return_false’ );
 ```

```
    remove_action( ‘wp_head’, ‘feed_links_extra’, 3 ); //去除评论feed
```

```
    remove_action( ‘wp_head’, ‘feed_links’, 2 ); //去除文章feed
```

```
    remove_action( ‘wp_head’, ‘rsd_link’ ); //针对Blog的远程离线编辑器接口
```

```
    remove_action( ‘wp_head’, ‘wlwmanifest_link’ ); //Windows Live Writer接口
```

```
    remove_action( ‘wp_head’, ‘index_rel_link’ ); //移除当前页面的索引
```

```
    remove_action( ‘wp_head’, ‘parent_post_rel_link’, 10, 0 ); //移除后面文章的url
```

```
    remove_action( ‘wp_head’, ‘start_post_rel_link’, 10, 0 ); //移除最开始文章的url
```

```
    remove_action( ‘wp_head’, ‘wp_shortlink_wp_head’, 10, 0 );//自动生成的短链接
```

```
    remove_action( ‘wp_head’, ‘adjacent_posts_rel_link’, 10, 0 ); ///移除相邻文章的url
```

```
    remove_action( ‘wp_head’, ‘wp_generator’ ); // 移除版本号
```

```
//禁用embeds功能移除wp-embed.min.js
function disable_embeds_init() {
  /* @var WP $wp */
  global $wp;

  // Remove the embed query var.
  $wp->public_query_vars = array_diff( $wp->public_query_vars, array(
    'embed',
  ) );

  // Remove the REST API endpoint.
  remove_action( 'rest_api_init', 'wp_oembed_register_route' );

  // Turn off
  add_filter( 'embed_oembed_discover', '__return_false' );

  // Don't filter oEmbed results.
  remove_filter( 'oembed_dataparse', 'wp_filter_oembed_result', 10 );

  // Remove oEmbed discovery links.
  remove_action( 'wp_head', 'wp_oembed_add_discovery_links' );

  // Remove oEmbed-specific JavaScript from the front-end and back-end.
  remove_action( 'wp_head', 'wp_oembed_add_host_js' );
  add_filter( 'tiny_mce_plugins', 'disable_embeds_tiny_mce_plugin' );

  // Remove all embeds rewrite rules.
  add_filter( 'rewrite_rules_array', 'disable_embeds_rewrites' );
}
add_action( 'init', 'disable_embeds_init', 9999 );
/**
 * Removes the 'wpembed' TinyMCE plugin.
 *
 * @since 1.0.0
 *
 * @param array $plugins List of TinyMCE plugins.
 * @return array The modified list.
 */
function disable_embeds_tiny_mce_plugin( $plugins ) {
  return array_diff( $plugins, array( 'wpembed' ) );
}
/**
 * Remove all rewrite rules related to embeds.
 *
 * @since 1.2.0
 *
 * @param array $rules WordPress rewrite rules.
 * @return array Rewrite rules without embeds rules.
 */
function disable_embeds_rewrites( $rules ) {
  foreach ( $rules as $rule => $rewrite ) {
    if ( false !== strpos( $rewrite, 'embed=true' ) ) {
      unset( $rules[ $rule ] );
    }
  }

  return $rules;
}
/**
 * Remove embeds rewrite rules on plugin activation.
 *
 * @since 1.2.0
 */
function disable_embeds_remove_rewrite_rules() {
  add_filter( 'rewrite_rules_array', 'disable_embeds_rewrites' );
  flush_rewrite_rules();
}
register_activation_hook( __FILE__, 'disable_embeds_remove_rewrite_rules' );

/**
 * Flush rewrite rules on plugin deactivation.
 *
 * @since 1.2.0
 */
function disable_embeds_flush_rewrite_rules() {
  remove_filter( 'rewrite_rules_array', 'disable_embeds_rewrites' );
  flush_rewrite_rules();
}
register_deactivation_hook( __FILE__, 'disable_embeds_flush_rewrite_rules' );
```

```
    //移除Wordpress头部加载DNS预先获取（dns-prefectch）
    function remove_dns_prefetch( $hints, $relation_type ) {
    if ( ‘dns-prefetch’ === $relation_type ) {
    return array_diff( wp_dependencies_unique_hosts(), $hints );
    }

    return $hints;
    }
    add_filter( ‘wp_resource_hints’, ‘remove_dns_prefetch’, 10, 2 );
```

```
 禁止 favicon.ico 请求

favicon.ico 图标用于收藏夹图标和浏览器标签上的显示，如果不设置，浏览器会请求网站根目录的这个图标，如果网站根目录也没有这图标会产生 404。出于优化的考虑，要么就有这个图标，要么就禁止产生这个请求。

在做 H5 混合应用的时候，不希望产生 favicon.ico 的请求。

可以在页面的 <head> 区域，加上如下代码实现屏蔽：

<link rel="icon" href="data:;base64,=">

或者详细一点

<link rel="icon" href="data:image/ico;base64,aWNv">

当然，既然是 dataURL 方式，IE < 8 等 old brower 就别想了 ╮(╯-╰)╭
```
