---
layout: post
meta_keywords: javascript, instagram, api, web app
meta_description: How to build a simple web app with JavaScript, for searching Instagram's photos by tag.
comment_id: eduvoyage-1
title: Instagram Web App Tutorial Part 1
short: Instagram Web App Tutorial Part 1
pretty_date: Wednesday, 18 April 2012
---


This post will document my attempt at creating a simple, single page web app, allowing a visitor to search Instagram for photos by tag. You can see the working app [here](http://grammy.eduvoyage.com). App was developed on a webkit browser (Google Chrome).

You can download code as a zipped package from [github](https://github.com/osahyoun/instagram-search/zipball/v0.1), or [clone the codebase](https://github.com/osahyoun/instagram-search).

Getting started, I visit Instagram's [API documentation](http://instagr.am/developer/) to learn how I can search for photos by tag. Registration is required, so I follow the instructions under **GETTING STARTED**.

I find the relevant API end point [here](http://instagr.am/developer/endpoints/tags/). It takes the form:

{% highlight bash %}
GET /tags/{tag-name}/media/recent
{% endhighlight %}

It responds with a list of recently tagged photos in JSON. The API supports JSONP - things are looking good.

Docs provide an example request:

{% highlight bash %}
https://api.instagram.com/v1/tags/snow/media/recent?client_id=CLIENT-ID
{% endhighlight %}

Replacing `CLIENT-ID` with my own, I paste the URL into a browser to see what the JSON object looks like. I could copy and paste the response into a file to use as sample data for developing against, but I can't be bothered right now. Perhaps later.

I'm ready to start getting stuff down, so I create the necessary directories and files for my project:

{% highlight bash %}
omar:~ admin$ mkdir -p instagram/{images,javascripts,stylesheets}
omar:~ admin$ cd instagram
omar:~ admin$ touch index.html javascripts/application.js stylesheets/application.css
{% endhighlight %}


I add some basic markup to <code>index.html</code>. I'll be using [jQuery](http://jquery.com), so I load it in the document's head:

{% highlight html %}
<!DOCTYPE html>
<html>
<head>

  <script src='https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js' type='text/javascript' charset='utf-8'></script>
  <script src='javascripts/application.js' type='text/javascript' charset='utf-8'></script>
  <link rel='stylesheet' href='stylesheets/application.css' type='text/css' media='screen'>

</head>
<body>

  <div id='photos-wrap'>
  </div>

</body>
</html>
{% endhighlight %}

I open up `appliation.js` and start writing code. So as not to pollute the global namespace, I'll wrap my code in an anonymous function, exposing only a single method, `search`, to the global namespace (I love minimalist APIs). The method will take a string (a photo tag) as its only parameter.

{% highlight javascript %}
var Instagram = {};

(function(){

 Instagram.search = search;
})();

Instagram.search('cats');
{% endhighlight %}


I load up `index.html` on Google Chrome so I can start debugging. With 'Developer Tools' enabled and the 'console' panel selected, I see:

{% highlight javascript %}

Uncaught ReferenceError: search is not defined

{% endhighlight %}

So, I define it:

{% highlight javascript %}
(function(){

  function search(tag){
    console.log(tag);
  }

  Instagram.search = search;
})();

Instagram.search('cats');
{% endhighlight %}


Reloading the page, I see the error has gone... I'm making progress.

Going to flesh out my function, `search`. I'll use jQuery's `getJSON` function for loading JSON-encoded data from Instagram using a GET HTTP request. See documentation [here](http://api.jquery.com/jQuery.getJSON/).

At a minimum, the method takes a request URL. I also pass it a `success` handler, so I can manage the JSON encoded data which is sent back after a successful request.

{% highlight javascript %}
function search(tag){
  $.getJSON(url, toScreen);
}
{% endhighlight %}

Both `url` and `toScreen` need to be defined:

{% highlight javascript %}
function toScreen(data){
  console.log(data);
}

function search(tag){
  var url = "https://api.instagram.com/v1/tags/" + tag + "/media/recent?callback=?&amp;client_id=XXXXXXXXX"
  $.getJSON(url, toScreen);
}
{% endhighlight %}

Refreshing Chrome I see the returned JSON object printed to the JavaScript console. Using the console I drill down into the returned object. I see the photos are contained within an array called `data`:


{% highlight javascript %}
- Object
  - data: Array[20]
    - 0: Object
      + caption: Object
      + comments: Object
        created_time: "1334402906"
        filter: "Nashville"
        id: "169306311223447303_5913362"
      - images: Object
        + low_resolution: Object
        - standard_resolution: Object
          height: 612
          url: "http://distilleryimage7.instagram.com/f3f8d7b2862411e19dc71231380fe523_7.jpg"
          width: 612
        + thumbnail: Object
        + likes: Object
          link: "http://instagr.am/p/JZfzFqtI8H/"
          location: Object
          tags: Array[1]
          type: "image"
          user: Object

(-) collapsed object. (+) expanded object.
{%endhighlight%}

I update `toScreen` to iterate through the `data` object, appending each photo to the browser:

{% highlight javascript %}
function toScreen(photos){

  // Using jQuery's generic iterator function:
  // jQuery.each http://api.jquery.com/jQuery.each/

  $.each(photos.data, function(index, photo){

    // I'll construct the image tag on the fly.
    // The images property contains objects representing images of
    // varying quality. I'll give low_resulution a try.

    photo = "<img src='"+ photo.images.low_resolution.url + "' />";

    $('div#photos-wrap').append(photo);
  });
}
{% endhighlight %}

Refreshing the browser, I see 20 cat photos loading... so much cuteness on one page is hard to manage.

Now's a good time to introduce a little more markup so I can start applying some styling.

I jot down how I'd like each photo to be represented as HTML. Attribute values which will be different for each photo I wrap with curly braces:

{% highlight html %}
<div class='photo'>
  <a href='{photo_url}' target='_blank'><img class='main' src='{photo}' width='250' height='250' /></a>
  <img class='avatar' width='40' height='40' src='{avatar_url}' />
  <span class='heart'><strong>{like_count}</strong></span>
</div>
{% endhighlight %}

I now insert this markup into the $.each iterator, replacing the curly braced attribute markers with the relevant datum:

{% highlight javascript %}
$.each(photos.data, function(index, photo){
  photo = "<div class='photo'>" +
    "<a href='"+ photo.link +"' target='_blank'>"+
      "<img class='main' src='" + photo.images.low_resolution.url + "' width='250' height='250' />" +
    "</a>" +
    "<img class='avatar' width='40' height='40' src='"+photo.user.profile_picture+"' />" +
    "<span class='heart'><strong>"+photo.likes.count+"</strong></span>" +
  "</div>";

  $('div#photos-wrap').append(photo);
});
{% endhighlight %}

Refreshing the browser I see this works... but my `toScreen` function now looks forsaken. All that string concatenation inside the `jQuery.each` callback makes me angry/thirsty/feverish.

The HTML markup deserves to have it's own object, where it can safely exist, far from the dangerous machinery operating inside `toScreen`.

So...

{% highlight javascript %}
// Instantiate empty objects.
var Instagram = {};
Instagram.Template = {};

// HTML markup goes here, please!
Instagram.Template.Views = {

  "photo": "<div class='photo'>" +
            "<a href='{url}' target='_blank'><img class='main' src='{photo_url}' width='250' height='250' /></a>" +
            "<img class='avatar_url' width='40' height='40' src='{avatar}' />" +
            "<span class='heart'><strong>{like_count}</strong></span>" +
          "</div>"
};

(function(){

  function toScreen(photos){
    $.each(photos.data, function(index, photo){

      // Undefined function toTemplate, takes
      // the photo object and returns markup
      // ready for display.

      photo = toTemplate(photo);
      $('div#photos-wrap').append(photo);
    });
  }

  function search(tag){
    var url = "https://api.instagram.com/v1/tags/" + tag + "/media/recent?callback=?&client_id=a307c0d0dada4b77b974766d71b72e0e";
    $.getJSON(url, toScreen);
  }


  Instagram.search = search;
})();

Instagram.search('cats');
{% endhighlight %}

Refreshing the browser I get `Uncaught ReferenceError: toTemplate is not defined`. I'll fix that...

{% highlight javascript %}
function toTemplate(photo){
  photo = {
    like_count: photo.likes.count,
    avatar_url: photo.user.profile_picture,
    photo_url: photo.images.low_resolution.url,
    url: photo.link
  };

  return Instagram.Template.generate('photo', Instgram.Teamplate.Views['photo']);
}
{%endhighlight%}

`Instagram.Template.generate` is undefined. I plan to create a function which finds strings matching property names in a passed object, replacing them with the corresponding values.

{% highlight   javascript %}
// A simple (it does the job) function for template parsing.
Instagram.Template.generate = function(template, photo){

  // Define variable for regular expression.
  var re;

  // Fetch template.
  template = Instagram.Template.Views[template];

  // Loop through the passed photo object.
  for(var attribute in photo){

    // Generate a regular expression.
    re = new RegExp("{" + attribute + "}","g");

    // Apply the regular expression instance with 'replace'.
    template = template.replace(re, photo[attribute]);
  }

  return template;
};
{% endhighlight %}

I refresh the browser; things are coming together. Time to introduce the search form:

{% highlight html %}
<body>
  <div id='photos-wrap'>
    <form id='search'>
      <button type='submit' id='search-button' tabindex='2'>
        <span class='button-content'>Search</span>
      </button>
      <div class='search-wrap'>
        <input class='search-tag' type='text' tabindex='1' />
      </div>
    </form>
  </div>
</body>
{% endhighlight %}

I'll bind an event handler to the form button, so I can invoke my `search` method whenever the form is submitted:

{% highlight javascript %}
$(function(){

  // Bind an event handler to the `click` event on the form's button
  $('form#search button').click(function(){
    // Extract the value of the search input text field.
    var tag = $('input.search-tag').val();

    // Invoke `search`, passing `tag`.
    Instagram.search(tag);
  });

  // Start with a search on cats. Humanity loves cat pictures, right?
  Instagram.search('cats');
});
{% endhighlight %}

The end of my first iteration is drawing near. I still need to slap on some makeup, which I'll do shortly. First, I want to revisit some code I'm not too happy with:

{% highlight javascript %}
function toScreen(photos){
  ....
  // Appending new photos to the bottom of 'body' - new stuff isn't visible
  // unless you scroll down the page. I want to 'prepend'!

  - $('div#photos-wrap').append(photo);
  + $('div#photos-wrap').prepend(photo);
  ....
}
{% endhighlight %}

Introducing an object for holding configuration data, and a new function for concatenating the request URL:

{% highlight javascript %}
+ Instagram.Config = {
+  clientID: "XXXXXXXXXXXXX";,
+  apiHost: "https://api.instagram.com";
+ };

  (function(){
  ...

+   function generateUrl(tag){
+     var config = Instagram.config;
+     return config.apiHost + "/v1/tags/" + tag + "/media/recent?callback=?&amp;client_id=" + config.clientID;
+   }


    function search(tag){
-     var url = "https://api.instagram.com/v1/tags/" + tag + "/media/recent?callback=?&amp;client_id=a307c0d0dada4b77b974766d71b72e0e";
-     $.getJSON(url, toScreen);
+     $.getJSON(generateUrl(tag), toScreen);
    }

  ...
  })();
{% endhighlight %}

Calling `$.prepend` for every photo is wasteful. Why not concatenate each photo string, _prepending_ the final result.

{% highlight javascript %}
  function toScreen(photos){
+   var html = "";
    $.each(photos.data, function(index, photo){
-     photo = toTemplate(photo);
-     $("div#photos-wrap").prepend(photo);
+     html += toTemplate(photo);
    });
+   $("div#photos-wrap").prepend(html);
  }
{% endhighlight %}

Ok. I've slapped on some makeup - see `stylesheets/application.css`, and I think we're good for a first go.

In another iteration it might be worth implementing the following features:

* Error handling (gracefully deal with invalid tags, API server down...).
* Bookmarking searches, for future reference.
* Marking favourite photos for quick retrieval at a later date.
* Add pagination.
* Displaying more photo data (username, comments).