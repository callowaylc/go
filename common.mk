comma:= ,
empty:=
space:= $(empty) $(empty)
define logger
@ logger -sp "$(if $(3),$(3),DEBUG)" "$(1)" -- \
		target=$(@) \
		pid=$$$$ \
		preqs=$(subst $(space),$(comma),$(?)) \
		$(2)
endef
