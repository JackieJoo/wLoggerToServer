
if( typeof module !== 'undefined' )
require( '../staging/abase/printer/printer/Logger.s' );


var _ = wTools;

var logger = new wLogger();
var colors = Object.keys( _.color.ColorMapShell );
logger.backgroundColor = 'black'
colors.forEach( function (color)
{
  logger.foregroundColor = color;
  logger.log( color );
} )
// colors.forEach( function (color)
// {
//   logger.backgroundColor = color;
//   logger.log( color );
// } )
