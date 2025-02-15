window.PostUploadForm = (form, progress) ->
  XHRLevel2 = 'XMLHttpRequest' of window and (new XMLHttpRequest).upload?
  SupportsFormData = 'FormData' of window
  if !XHRLevel2 or !SupportsFormData
    return
  @form_element = form
  @cancel_element = @form_element.down('.cancel')
  @progress = progress
  @document_title = document.documentElement.down('TITLE')
  @document_title_orig = @document_title.textContent
  @current_request = null
  @form_element.on 'submit', @form_submit_event.bindAsEventListener(this)
  @cancel_element.on 'click', @click_cancel.bindAsEventListener(this)
  document.on 'keydown', @document_keydown_event.bindAsEventListener(this)
  return

PostUploadForm::set_progress = (f) ->
  percent = f * 100
  @progress.down('.upload-progress-bar-fill').style.width = percent + '%'
  @document_title.textContent = @document_title_orig + ' (' + percent.toFixed(0) + '%)'
  return

PostUploadForm::request_starting = ->
  @form_element.down('.submit').hide()
  @cancel_element.show()
  @progress.show()
  document.documentElement.addClassName 'progress'
  return

PostUploadForm::request_ending = ->
  @form_element.down('.submit').show()
  @cancel_element.hide()
  @progress.hide()
  @document_title.textContent = @document_title_orig
  document.documentElement.removeClassName 'progress'
  return

PostUploadForm::document_keydown_event = (e) ->
  key = e.charCode
  if !key
    key = e.keyCode

  # Opera
  if key != Event.KEY_ESC
    return
  @cancel()
  return

PostUploadForm::click_cancel = (e) ->
  e.stop()
  @cancel()
  return

PostUploadForm::form_submit_event = (e) ->
  # This submit may have been stopped by User.run_login_onsubmit.
  if e.stopped
    return
  if @current_request?
    return
  $('post-exists').hide()
  $('post-upload-error').hide()

  # If the files attribute isn't supported, or we have no file (source upload), use regular
  # form submission.
  post_file = $('post_file')
  if !post_file.files? or post_file.files.length == 0
    return
  e.stop()
  @set_progress 0
  @request_starting()
  formData = new FormData(@form_element)

  onprogress = (e) =>
    console.log 'hi'
    done = e.loaded
    total = e.total
    progress = if total > 0 then done / total else 1

    @set_progress progress

  @current_request = jQuery.ajax '/post/create.json',
    contentType: false
    data: formData
    dataType: 'json'
    method: 'POST'
    processData :false
    xhr: =>
      xhr = new XMLHttpRequest
      xhr.upload.addEventListener('progress', onprogress)
      xhr
  .always =>
    @current_request = null
    @request_ending()
  .done (json) =>
    # If a post/similar link was given and similar results exists, go to them.  Otherwise,
    # go to the new post.
    window.location.href =
      if json.similar_location && json.has_similar_hits
        json.similar_location
      else
        json.location
  .fail (xhr) =>
    json = xhr.responseJSON

    if json? && json.location
      a = document.querySelector('#post-exists-link')
      a.text = "post ##{json.post_id}"
      a.href = json.location
      document.querySelector('#post-exists').style.display = ''
      return

    errorLabel = document.querySelector('#post-upload-error')
    errorLabel.text = json?.reason ? 'unknown error'
    errorLabel.style.display = ''

  return

# Cancel the running request, if any.
PostUploadForm::cancel = ->
  if !@current_request?
    return

  # Don't clear this.current_request; it'll be done by the onComplete callback.
  @current_request.abort()
  return

# When file_field is changed to an image, run an image search and put a summary in
# results.
window.UploadSimilarSearch = (file_field, results) ->
  if !ThumbnailUserImage
    return
  @file_field = file_field
  @results = results
  file_field.on 'change', @field_changed_event.bindAsEventListener(this)
  return

UploadSimilarSearch::field_changed_event = (event) ->
  @results.hide()
  if !@file_field.files? or @file_field.files.length == 0
    return
  @results.innerHTML = 'Searching...'
  @results.show()
  file = @file_field.files[0]
  similar = new ThumbnailUserImage(file, @thumbnail_complete.bind(this))
  return

UploadSimilarSearch::thumbnail_complete = (result) ->
  if !result.success
    @results.innerHTML = 'Image load failed.'
    @results.style.display = ''
    return

  jQuery.ajax '/post/similar.json',
    data:
      url: result.canvas.toDataURL()
    dataType: 'json'
    method: 'POST'
  .always =>
    @results.innerHTML = ''
    @results.style.display = ''
  .done (json) =>
    if json.posts.length > 0
      posts = []
      shownPosts = 3
      makeUrl =
          if User.get_use_browser()
            (post) => "/post/browse##{post.id}"
          else
            (post) => "/post/show/#{post.id}"
      posts = json.posts.slice(0, shownPosts).map (post) =>
        "<a href='#{makeUrl(post)}'>post ##{post.id}</a>"
      seeAll = "<a href='/post/similar?search_id='#{json.search_id}'>(see all)</a>"
      html = "Similar posts #{seeAll}: #{posts.join(', ')}"

      if json.posts.length > shownPosts
        remainingPosts = json.posts.length - shownPosts
        html += " (#{remainingPosts} more)"

      message = html
    else
      message = 'No similar posts found.'

    @results.innerHTML = message
  .fail (xhr) =>
    @results.innerHTML = xhr.responseJSON?.reason ? 'unknown error'
