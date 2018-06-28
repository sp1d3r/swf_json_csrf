<?php
header("Location: ".substr($_SERVER['QUERY_STRING'],9), true, 307);
?>
