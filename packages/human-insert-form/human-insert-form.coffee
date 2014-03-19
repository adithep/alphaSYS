HUMAN_FORM = new Meteor.Collection(null, idGeneration: "MONGO")
CITIES = new Meteor.Collection(null, {idGeneration:"MONGO"})
pargs = {}
pargs.session = false

Deps.autorun ->
  if Session.equals("subscription", true)
    HUMAN_FORM.remove({})
    human = DATA.findOne(doc_name: "humans", doc_schema: "doc_schema")
    if human
      ADATA.find({p_doc_schema: human._id, input_starting: true}, {sort: input_starting_sort: 1}).map (doc) ->
        doc._sid = doc._id
        delete doc._id
        HUMAN_FORM.insert(form_element: [doc], _sid: doc._sid, input_size: doc.input_size, input_starting: true)

Template.add_contact.events

  'click .save_human_json': (e, t) ->
    Meteor.call "save_human_json"
    
  'click .click-input': (e, t) ->
    t_id = e.currentTarget.dataset.id
    id = new Meteor.Collection.ObjectID(t_id)
    obj = ADATA.findOne(_id: id)
    if (ADATA.find(parent: obj._id).count() is 0) or (obj.object_keys_arr)
      obj._sid = obj._id
      delete obj._id
      if obj.array
        HUMAN_FORM.insert(form_element: [obj], _sid: obj._sid, input_size: obj.input_size)
      else
        if HUMAN_FORM.findOne(_sid: obj._sid)
          HUMAN_FORM.remove(_sid: obj._sid)
        else
          HUMAN_FORM.insert(form_element: [obj], _sid: obj._sid, input_size: obj.input_size)
    else
      obj = ojts(obj._id)
      HUMAN_FORM.insert(obj)

  'click .contact_form .close_input': (e, t) ->
    id = new Meteor.Collection.ObjectID(e.currentTarget.dataset.id)
    HUMAN_FORM.remove(_id: id)

  'keypress .contact_form': (e, t) ->
    if e.which is 13
      e.preventDefault()

  'blur .contact_form input[name=mobile]': (e, t) ->
    small = $(e.currentTarget).next()
    if e.currentTarget.dataset.value is "" or e.currentTarget.dataset.value is undefined
      e.currentTarget.value = ""
      small.html("invalid. try inserting country code")
      small.hide()
    else
      a = formatInternational(e.currentTarget.dataset.country, e.currentTarget.dataset.value)
      e.currentTarget.value = e.currentTarget.dataset.value
      small.hide()
    return

  'keyup .contact_form input[name=mobile]': (e, t) ->
    small = $(e.currentTarget).next()
    small.show()
    number = e.currentTarget.value
    e164 = formatE164("TH", number)
    if isValidNumber(e164, "TH")
      inter = formatInternational("TH", e164)
      small.html("#{inter} valid!")
      small.removeClass("warning").addClass("success")
      e.currentTarget.dataset.value = e164
      e.currentTarget.dataset.country = "TH"
      return
    else
      if number.length >= 2
        if number.substring(0, 1) is "+"
          if number.length >= 3
            sub = number.substring(1, 2)
        else
          sub = number.substring(0, 2)
        countryCode = DATA.findOne(callingCode: sub)
        if countryCode
          e164_1 = formatE164(countryCode.cca2, number)
          if isValidNumber(e164_1, countryCode.cca2)
            inter_1 = formatInternational(countryCode.cca2, e164_1)
            small.html("#{inter_1} valid!")
            small.removeClass("warning").addClass("success")
            e.currentTarget.dataset.value = e164_1
            e.currentTarget.dataset.country = countryCode.cca2
            return
          else
            small.html("invalid. try inserting country code")
            small.removeClass("success").addClass("warning")
            e.currentTarget.dataset.value = ""
            e.currentTarget.dataset.country = ""
            return
        else
          small.html("invalid. try inserting country code")
          small.removeClass("success").addClass("warning")
          e.currentTarget.dataset.value = ""
          e.currentTarget.dataset.country = ""
          return
      else
        small.html("invalid. try inserting country code")
        small.removeClass("success").addClass("warning")
        e.currentTarget.dataset.value = ""
        e.currentTarget.dataset.country = ""
        return

  'click .contact_form .form_submit': (e, t) ->
    arr = []
    index_p = 0
    parentdiv = t.findAll('.parentdiv')
    while index_p < parentdiv.length
      barr = []
      index = 0
      input = $(parentdiv[index_p]).find(':input')
      while index < input.length
        value = undefined
        id = new Meteor.Collection.ObjectID(input[index].dataset.sid)
        if input[index].localName is 'select'
          if input[index].value isnt "" and input[index].value isnt undefined
            value = new Meteor.Collection.ObjectID(input[index].value)
        else if $(input[index]).hasClass('input_select')
          if input[index].dataset.value isnt "" and input[index].dataset.value isnt undefined
            value = new Meteor.Collection.ObjectID(input[index].dataset.value)
        else
          value = input[index].value
        if value isnt "" and value isnt undefined
          barr[index] = {id: id, value: value}
          index++
        else
          input.splice(index, 1)
        
      if barr.length > 0
        arr[index_p] = barr
        index_p++
      else
        parentdiv.splice(index_p, 1)
      
    console.log arr
    Meteor.call "insert_human", arr

  'focus .contact_form .input_select': (e, t) ->
    if e.currentTarget.value is ""
      $('.input_select_box').hide()
    else
      $('.input_select_box').show()

  'blur .contact_form .input_select': (e, t) ->
    if e.currentTarget.value isnt ""
      if $('.blue_color').html()
        e.currentTarget.value = $('.blue_color').html()
        e.currentTarget.dataset.value = $('.blue_color').data('value')
      if e.currentTarget.dataset.value is ""
        e.currentTarget.value = ""
    else
      e.currentTarget.value = ""
      e.currentTarget.dataset.value = ""
    $('.input_select_box').hide()
    return

  'mouseover .contact_form .lala_item': (e, t) ->
    $('.lala_item').removeClass('blue_color')
    $(e.target).addClass('blue_color')
    b = $(e.target).html()
    $('.input_select').val(b)

  'click .contact_form .input_select': (e, t) ->
    if e.currentTarget.value isnt ""

      $('.input_select_box').show()
          
      params = {input: e.currentTarget.value, field: e.currentTarget.dataset.schema}

      subs = Meteor.subscribe "cities_list", params
        
      if pargs.session
        pargs.session.stop()

      pargs.session = subs
      return

  'keyup .contact_form .input_select': (e, t) ->
    if e.which is 40
      if $('.lala_item').hasClass("blue_color") is false
        $('.input_select_list li:first-child').addClass("blue_color")
      else
        $(".blue_color").removeClass("blue_color").next().addClass("blue_color")

      b = $(".blue_color").html()
      if b
        e.currentTarget.value = b
      return

    else if e.which is 38
      if $('.lala_item').hasClass("blue_color") is false
        $('.input_select_list li:first-child').addClass("blue_color")
      else
        $(".blue_color").removeClass("blue_color").prev().addClass("blue_color")

      b = $(".blue_color").html()
      if b
        e.currentTarget.value = b
      return
    else if e.which is 13
      if $('.lala_item').hasClass("blue_color")
        d = $(".blue_color").html()
        if d
          e.currentTarget.value = d
          e.currentTarget.dataset.value = $('.blue_color').data('value')
      $('.input_select_box').hide()
      if pargs.session
        pargs.session.stop()

    else if e.which is 27
      e.currentTarget.value = ""
      e.currentTarget.dataset.value = ""
      $('.input_select_box').hide()
      if pargs.session
        pargs.session.stop()

    else
      if e.currentTarget.value is ""
        $('.input_select_box').hide()
      else
        
        $('.input_select_box').show()

      if e.currentTarget.value isnt ""
          

        params = {input: e.currentTarget.value, field: e.currentTarget.dataset.schema}

        Meteor.subscribe "cities_list", params, ->
          d = new Meteor.Collection.ObjectID(e.currentTarget.dataset.schema)
          a = ADATA.find({$and: [{doc_schema: d}, $or: [{doc_name: { $regex: params.input, $options: 'i' }}, {country: { $regex: params.input, $options: 'i' }}]]}, { limit: 5} ).fetch()
          if a
            console.log a
            a[0].e_class = "blue_color"
            CITIES.remove({})
            _.map a, (obj) ->
              CITIES.insert(obj)
          
        return


Template.add_contact.helpers
  schema: ->
    human = DATA.findOne(doc_name: "humans", doc_schema: "doc_schema")
    if human
      ADATA.find({p_doc_schema: human._id, button_name: {$exists: true}})
  input_element: ->
    HUMAN_FORM.find()

  input_select_helper: ->
    CITIES.find()

  select_options: (id) ->
    piece = ADATA.findOne(_id: id)
    ADATA.find({doc_schema: piece.value_schema})

  select_options_arr: (id) ->
    ADATA.find(parent: id).fetch()

  h_input_large: ->
    a = 'large-'+this.input_size+ ' columns left parentdiv'
    a
  h_input_small: ->
    a = 'small-'+this.input_small_size+ ' columns'
    a
  h_select_small: ->
    a = 'small-'+this.select_small_size+ ' columns'
    a

Template.display_humans.helpers
  humans: ->
    human = DATA.findOne(doc_name: "humans", doc_schema: "doc_schema")
    if human
      ADATA.find(doc_schema: human._id)
  dude: (arg, id) ->
    i = 0
    item = []
    while i < arg.length
      if typeof arg[i] is 'string'
        obj = {}
        obj.$value = arg[i]
        obj.$index = i
        obj.__id = id
      else
        obj = arg[i]
        obj.$index = i
        obj.__id = id
      item[i] = obj
      i++
    item

is_editing = (id) ->
  Session.equals('is_editing-'+id, true)
set_editing = (id, is_editing) ->
  Session.set('is_editing-'+id, is_editing)
set_path = (id, path) ->
  Session.set('path-'+id, path)

Template.inline_editor.helpers
  is_editing: (sid) ->
    if sid.index
      is_editing(sid.id + sid.sid + sid.index)
    else
      is_editing(sid.id + sid.sid)
  kadui: (a) ->
    console.log this
Template.__display_humans.events
  'click .inlineedit': (e, t) ->
    if e.currentTarget.dataset.index isnt '' and e.currentTarget.dataset.index isnt undefined and e.currentTarget.dataset.index isnt '0'
      task = t.data._id._str + e.currentTarget.dataset.sid + e.currentTarget.dataset.index
    else
      task = t.data._id._str + e.currentTarget.dataset.sid
    set_editing(task, true)
    set_path(task, e.currentTarget.dataset.path)
  'click .cancel': (e, t) ->
    if e.currentTarget.dataset.index isnt '' and e.currentTarget.dataset.index isnt undefined and e.currentTarget.dataset.index isnt '0'
      task = t.data._id._str + e.currentTarget.dataset.sid + e.currentTarget.dataset.index
    else
      task = t.data._id._str + e.currentTarget.dataset.sid
    set_editing(task, false)
  'click .submit': (e, t) ->
    if e.currentTarget.dataset.index isnt '' and e.currentTarget.dataset.index isnt undefined and e.currentTarget.dataset.index isnt '0'
      task = t.data._id._str + e.currentTarget.dataset.sid + e.currentTarget.dataset.index
    else
      task = t.data._id._str + e.currentTarget.dataset.sid
    set_editing(task, false)


ojts = (id) ->
  arr = []
  input_size = 0
  ADATA.find(parent: id).forEach (doc) ->
    if ADATA.find(parent: doc._id).count() is 0
      doc._sid = doc._id
      delete doc._id
      input_size = input_size + doc.input_size
      arr.push(doc)
  obj = {form_element: arr, _sid: id, input_size: input_size}
  obj
