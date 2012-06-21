---
layout: post
meta_keywords: javascript, instagram, api, web app, pagination
meta_description: Continuing from last weeks tutorial, I'll be implementing pagination.
comment_id: eduvoyage-2
title: Instagram Web App Tutorial Part 2 - Implementing Pagination
short: Instagram Web App Tutorial Part 2
pretty_date: Wednesday, 27 April 2012
---

<p class='intro'>
This post follows on from <a href='http://eduvoyage.com/instagram-search-app.html'>last week's</a>. I'll be implementing pagination.
</p>

A working version of this app is located [here](http://grammy.eduvoyage.com), and you can download the source code from [github](https://github.com/osahyoun/instagram-search/zipball/v0.2).

I quite like google-image's solution to this problem, which is to have a single 'Show more results' button at the bottom of the page.

Instagram's API makes pagination a doddle. There's nothing in the API's [documentation](http://instagr.am/developer/endpoints/tags/) about pagination, but in the API's response there is an object property called `pagination`:

{% highlight javascript %}
"pagination": {
    "next_max_tag_id": "1335465136530",
    "deprecation_warning": "next_max_id and min_id are deprecated for this endpoint; use min_tag_id and max_tag_id instead",
    "next_max_id": "1335465136530",
    "next_min_id": "1335465556125",
    "min_tag_id": "1335465556125",
    "next_url": "https:\/\/api.instagram.com\/v1\/tags\/cats\/media\/recent?callback=jQuery17201362594123929739_1335440328560&_=133544032857&client_id=xxx&max_tag_id=1335465136530"
}
{% endhighlight %}

Within the object there's a property called `next_url`, which conveniently contains a prepared URL for accessing the next page of photos. Studying the URL you'll notice there's an additional parameter - `max_tag_id`, which can also be retrieved from the pagination object as `next_max_id`.

The plan then is to display the first page of photos, with a 'View More' button at the bottom of the page. The button will store the `max_tag_id` as a `data attribute`. When clicked, a handler will pass the `max_tag_id` as a query parameter in a request to Instagram's API.

Here's the markup for the button:

{% highlight html %}
<!-- index.html -->
<div class='paginate'>
  <a class='button'  style='display:none;' data-max-tag-id='' href='#'>View More...</a>
</div>
{% endhighlight %}

I've made a number of tweaks to the code since [part 1](http://eduvoyage.com/instagram-search-app.html), the most significant of which is the way I now generate the URL for querying the API:


{% highlight javascript %}
function generateResource(tag){
  var config = Instagram.Config;
  url = config.apiHost + "/v1/tags/" + tag + "/media/recent?callback=?&client_id=" + config.clientID;

  return function(max_id){
    if(typeof max_id === 'string' && max_id.trim() !== '') {
      url += "&max_id=" + max_id;
    }
    return url;
  };
}
{% endhighlight %}

Calling `generateResource` with a search string like 'cats' would return another function, which when invoked would then return the URL with 'cats' passed in the query string.

{% highlight bash %}
> var resource = generateResource('cats');
  undefined

> resource();
  "https://api.instagram.com/v1/tags/cats/media/recent?callback=?&client_id=xxx"

{% endhighlight %}

I can invoke `resource` at anytime. If and when the user wants to see the next page of photos I need only invoke `resource`, this time passing the `max ID` as a parameter. The returned string is the same URL as before, with 'cats' as the tag, but now also with the `max_id` query parameter slapped on to the end.

{% highlight bash %}
> var resource = generateResource('cats');
  undefined

> resource();
  "https://api.instagram.com/v1/tags/cats/media/recent?callback=?&client_id=xxx"

> resource('12345');
  "https://api.instagram.com/v1/tags/cats/media/recent?callback=?&client_id=xxx&max_id=12345"

{% endhighlight %}

The `search` function has changed to accommodate this new way of generating the query URL. `search` simply prepares the resource URL by invoking `generateResource` with the tag. The actual GET request to the API is delegated to a new function, `fetchPhotos`.

{% highlight javascript %}

function search(tag){
  resource = generateResource(tag);
  $('.paginate a').hide();
  $('#photos-wrap *').remove();
  fetchPhotos();
}
{% endhighlight %}

The `toScreen` function which previously appended photos to the screen, now also updates the **'view more'** button with the `max_id` for the next page of photos:

{% highlight javascript %}

function toScreen(photos){
  var photos_html = '';

  // Update data-max-tag-id with the next_max_id.
  $('.paginate a').attr('data-max-tag-id', photos.pagination.next_max_id)
                  .fadeIn();

  $.each(photos.data, function(index, photo){
    photos_html += toTemplate(photo);
  });

  $('div#photos-wrap').append(photos_html);
}

{% endhighlight %}

