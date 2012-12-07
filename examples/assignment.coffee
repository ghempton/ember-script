class Controller

  init: ->
    @x = @a.b.c
    [@x, @y] = [1, 2]

    local = [a, {b, c}, d, e]
    [@a, {b: @b, c: @c}, @d, @e] = local

  name: ~> @firstName + @lastName

  +computed name
  initials: ->
    @firstName.charAt(0) + ' ' + @lastName.charAt(0)

  +observer name
  nameChanged: ->
    console.log "name changed"
