{ ... }:

let
  # Curvas validadas en esta maquina. performance NO se toca aqui: es propiedad
  # de horus-gpu-watch, que la reescribe segun la fuente (alta en AC, = balanced
  # en bateria). asusd las persiste, pero declararlas aqui las hace reproducibles
  # en una instalacion nueva.
  quiet = "30c:0%,45c:0%,55c:0%,60c:0%,65c:15%,75c:30%,85c:50%,95c:70%";
  balanced = "30c:0%,45c:10%,55c:20%,60c:30%,70c:45%,80c:65%,90c:85%,100c:100%";
in
{
  systemd.services.horus-fan-curves = {
    description = "Curvas de ventilador quiet/balanced en asusd";
    after = [ "asusd.service" ];
    wants = [ "asusd.service" ];
    wantedBy = [ "multi-user.target" ];
    # asusctl vive fuera del store; mismo criterio que horus-gpu-watch.
    path = [ "/run/current-system/sw" ];
    serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
    script = ''
      for i in $(seq 1 15); do
        if asusctl fan-curve --mod-profile quiet --fan cpu --data "${quiet}" >/dev/null 2>&1; then
          asusctl fan-curve --mod-profile quiet --fan gpu --data "${quiet}"
          asusctl fan-curve --mod-profile quiet --enable-fan-curves true
          asusctl fan-curve --mod-profile balanced --fan cpu --data "${balanced}"
          asusctl fan-curve --mod-profile balanced --fan gpu --data "${balanced}"
          asusctl fan-curve --mod-profile balanced --enable-fan-curves true
          echo "curvas quiet/balanced aplicadas"
          exit 0
        fi
        sleep 2
      done
      echo "asusd no respondio tras 30s" >&2
      exit 1
    '';
  };
}
