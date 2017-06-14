( function _Chaining_test_s_( ) {

'use strict';

/*

to run this test
from the project directory run

npm install
node ./staging/abase/z.test/Chaining.test.s

*/

if( typeof module !== 'undefined' )
{

  require( '../printer/Logger.s' );

  var _ = wTools;

  _.include( 'wTesting' );

}

//

var _ = wTools;
var Parent = wTools.Testing;

//

var _escaping = function ( str )
{
  return _.toStr( str,{ escaping : 1 } );
}

function log()
{
  return arguments;
}

var fakeConsole =
{
  log : _.routineJoin( console,log ),
  error : _.routineJoin( console,console.error ),
  info : _.routineJoin( console,console.info ),
  warn : _.routineJoin( console,console.warn ),
}

function levelsTest( test )
{
  var logger = new wLogger( { output : fakeConsole });

  var l = new wLogger( { output : logger } );

  logger._dprefix = '-';
  l._dprefix = '-';

  test.description = 'case1 : ';
  logger.up( 2 );
  var got = l.log( 'abc' );
  var expected = l;
  test.identical( _escaping( got ), _escaping( expected ) );

  test.description = 'case2 : add 2 levels, first logger level must be  2';
  l.up( 2 );
  var got = logger.log( 'abc' );
  var expected = logger;
  test.identical( _escaping( got ), _escaping( expected ) );

  test.description = 'case3 : current levels of loggers must be equal';
  var got = l.level;
  var expected = logger.level;
  test.identical( got, expected );

  test.description = 'case4 : logger level - 2, l level - 4, text must have level 6 ';
  l.up( 2 );
  var got = l.log( 'abc' );
  var expected = l;
  test.identical( _escaping( got ), _escaping( expected ) );

  test.description = 'case5 : zero level';
  l.down( 4 );
  logger.down( 2 );
  var got = l.log( 'abc' );
  var expected = l;
  test.identical( _escaping( got ), _escaping( expected ) );

  if( Config.debug )
  {
    test.description = 'level cant be less then zero';
    test.shouldThrowError( function( )
    {
      l.down( 10 );
    })
  }

}

//

function chaining( test )
{
  function _onWrite( args ) { got.push( args.output[ 0 ] ) };

  test.description = 'case1: l1 must get two messages';
  var got = [];
  var l1 = new wLogger( { output : fakeConsole, onWrite : _onWrite } );
  var l2 = new wLogger( { output : l1 } );
  l2.log( '1' );
  l2.log( '2' );
  var expected = [ '1', '2' ];
  test.identical( got, expected );

  test.description = 'case2: multiple loggers';
  var got = [];
  var l1 = new wLogger( { output : fakeConsole, onWrite : _onWrite } );
  var l2 = new wLogger( { output : l1, onWrite : _onWrite } );
  var l3 = new wLogger( { output : l2 } );
  l2.log( 'l2' );
  l3.log( 'l3' );
  var expected = [ 'l2', 'l2', 'l3', 'l3' ];
  test.identical( got, expected );

  test.description = 'case3: multiple loggers';
  var got = [];
  var l1 = new wLogger( { output : fakeConsole, onWrite : _onWrite } );
  var l2 = new wLogger( { output : l1, onWrite : _onWrite } );
  var l3 = new wLogger( { output : l2, onWrite : _onWrite } );
  var l4 = new wLogger( { output : l3, onWrite : _onWrite } );
  l4.log( 'l4' );
  l3.log( 'l3' );
  l2.log( 'l2' );
  var expected =
  [
    'l4', 'l4', 'l4', 'l4',
    'l3', 'l3', 'l3',
    'l2', 'l2',
  ];
  test.identical( got, expected );

  test.description = 'case4: input test ';
  var got = [];
  var l1 = new wLogger( { output : fakeConsole, onWrite : _onWrite } );
  var l2 = new wLogger( { onWrite : _onWrite } );
  var l3 = new wLogger( { onWrite : _onWrite } );
  var l4 = new wLogger( { onWrite : _onWrite } );
  l3.inputFrom( l4 );
  l2.inputFrom( l3 );
  l1.inputFrom( l2 );

  l4.log( 'l4' );
  l3.log( 'l3' );
  l2.log( 'l2' );
  var expected =
  [
    'l4', 'l4', 'l4', 'l4',
    'l3', 'l3', 'l3',
    'l2', 'l2',
  ];
  test.identical( got, expected );

  // test.description = 'case5: l1->l2->l3 leveling off ';
  // var l1 = new wLogger();
  // var l2 = new wLogger();
  // var l3 = new wLogger();
  // l1.outputTo( l2, { combining : 'rewrite', leveling : '' } );
  // l2.outputTo( l3, { combining : 'rewrite', leveling : '' } );
  // l1.up( 2 );
  // l2.up( 2 );
  // var got =
  // [
  //   l1.level,
  //   l2.level,
  //   l3.level,
  // ];
  // var expected = [ 2, 2, 0 ];
  // test.identical( got, expected );
  //
  // test.description = 'case6: l1->l2->l3 leveling on ';
  // var l1 = new wLogger();
  // var l2 = new wLogger();
  // var l3 = new wLogger();
  // l1.outputTo( l2, { combining : 'rewrite', leveling : 'delta' } );
  // l2.outputTo( l3, { combining : 'rewrite', leveling : 'delta' } );
  // l1.up( 2 );
  // var got =
  // [
  //   l1.level,
  //   l2.level,
  //   l3.level,
  // ];
  // var expected = [ 2, 2, 2 ];
  // test.identical( got, expected );
}

//

function chainingParallel( test )
{
  function _onWrite( args ) { got.push( args.output[ 0 ] ) };

  test.description = 'case1: 1 -> *';
  var got = [];
  var l1 = new wLogger( { onWrite : _onWrite  } );
  var l2 = new wLogger( { onWrite : _onWrite  } );
  var l3 = new wLogger( { onWrite : _onWrite  } );
  var l4 = new wLogger();
  l4.outputTo( l3, { combining : 'append' } );
  l4.outputTo( l2, { combining : 'append' } );
  l4.outputTo( l1, { combining : 'append' } );

  l4.log( 'msg' );
  var expected = [ 'msg','msg','msg' ];
  test.identical( got, expected );

  test.description = 'case2: * -> 1';
  var got = [];
  var l1 = new wLogger( { output : fakeConsole, onWrite : _onWrite  } );
  var l2 = new wLogger();
  var l3 = new wLogger();
  var l4 = new wLogger();
  l2.outputTo( l1, { combining : 'rewrite' } );
  l3.outputTo( l1, { combining : 'rewrite' } );
  l4.outputTo( l1, { combining : 'rewrite' } );

  l2.log( 'l2' );
  l3.log( 'l3' );
  l4.log( 'l4' );
  var expected = [ 'l2','l3','l4' ];
  test.identical( got, expected );

  test.description = 'case3: *inputs -> 1';
  var got = [];
  var l1 = new wLogger( { output : fakeConsole, onWrite : _onWrite  } );
  var l2 = new wLogger();
  var l3 = new wLogger();
  var l4 = new wLogger();
  l1.inputFrom( l2, { combining : 'rewrite' } );
  l1.inputFrom( l3, { combining : 'rewrite' } );
  l1.inputFrom( l4, { combining : 'rewrite' } );

  l2.log( 'l2' );
  l3.log( 'l3' );
  l4.log( 'l4' );
  var expected = [ 'l2','l3','l4' ];
  test.identical( got, expected );

  test.description = 'case4: outputTo/inputFrom, remove some outputs ';
  var got = [];
  var l1 = new wLogger( { output : fakeConsole, onWrite : _onWrite  } );
  var l2 = new wLogger();
  var l3 = new wLogger();
  var l4 = new wLogger();
  l1.inputFrom( l2, { combining : 'rewrite' } );
  l1.inputFrom( l3, { combining : 'rewrite' } );
  l4.outputTo( l1, { combining : 'rewrite' } );

  l2.outputUnchain( l1 );
  l1.inputUnchain( l4 );

  l2.log( 'l2' );
  l3.log( 'l3' );
  l4.log( 'l4' );
  var expected = [ 'l3' ];
  test.identical( got, expected );

  // test.description = 'case5: l1->* leveling off ';
  // var l1 = new wLogger();
  // var l2 = new wLogger();
  // var l3 = new wLogger();
  // l1.outputTo( l2, { combining : 'rewrite', leveling : '' } );
  // l1.outputTo( l3, { combining : 'append', leveling : '' } );
  // l1.up( 2 );
  // var got =
  // [
  //   l1.level,
  //   l2.level,
  //   l3.level,
  // ];
  // var expected = [ 2, 0, 0 ];
  // test.identical( got, expected );
  //
  // test.description = 'case6: l1->* leveling on ';
  // var l1 = new wLogger();
  // var l2 = new wLogger();
  // var l3 = new wLogger();
  // l1.outputTo( l2, { combining : 'rewrite', leveling : 'delta' } );
  // l1.outputTo( l3, { combining : 'append', leveling : 'delta' } );
  // l1.up( 2 );
  // var got =
  // [
  //   l1.level,
  //   l2.level,
  //   l3.level,
  // ];
  // var expected = [ 2, 2, 2 ];
  // test.identical( got, expected );

  // !!! needs barringConsole = false
  // test.description = 'case7: input from console twice ';
  // var l1 = new wLogger({ output : null,onWrite : _onWrite });
  // var l2 = new wLogger({ output : null,onWrite : _onWrite });
  // l1.inputFrom( console );
  // l2.inputFrom( console );
  // var got = [];
  // console.log('something');
  // l1.inputUnchain( console );
  // l2.inputUnchain( console );
  // var expected = [ 'something', 'something' ];
  // test.identical( got, expected );
}

//

function outputTo( test )
{

  test.description = 'output already exist';

  test.identical( got, expected );
  test.shouldThrowError( function()
  {
    var l = new wLogger();
    l.outputTo( logger, { combining : 'append' } );
    l.outputTo( logger, { combining : 'append' } );
  });

  test.description = 'output already exist, combining : rewrite';
  var l = new wLogger();
  l.outputTo( logger, { combining : 'append' } );
  var got = l.outputTo( logger, { combining : 'rewrite' } );
  var expected = true;
  test.identical( got, expected );


  if( Config.debug )
  {
    test.description = 'no args';
    test.shouldThrowError( function()
    {
      logger.outputTo();
    });

    test.description = 'output is not a Object';
    test.shouldThrowError( function()
    {
      logger.outputTo( 'output', { combining : 'rewrite' } );
    });

    test.description = 'not allowed combining mode';
    test.shouldThrowError( function()
    {
      logger.outputTo( console, { combining : 'mode' } );
    });

    // test.description = 'not allowed leveling mode';
    // test.shouldThrowError( function()
    // {
    //   logger.outputTo( console, { combining : 'rewrite', leveling : 'mode' } );
    // });
  }
}

//

function outputUnchain( test )
{
  function _onWrite( args ) { got.push( args.output[ 0 ] ) };

  test.description = 'case1 delete l1 from l2 outputs, l2 still have one output';
  var got = [];
  var l1 = new wLogger( { onWrite : _onWrite  } );
  var l2 = new wLogger( { onWrite : _onWrite  } );
  l2.outputTo( l1, { combining : 'append' } );
  l2.outputUnchain( l1 )
  l2.log( 'msg' );
  var expected = [ 'msg' ];
  test.identical( got, expected );

  test.description = 'case2 delete l1 from l2 outputs, no msg transfered';
  var got = [];
  var l1 = new wLogger( { onWrite : _onWrite  } );
  var l2 = new wLogger();
  l2.outputTo( l1, { combining : 'rewrite' } );
  l2.outputUnchain( l1 );
  l2.log( 'msg' )
  var expected = [];
  test.identical( got, expected );

  test.description = 'case3: delete l1 from l2 outputs';
  var got = [];
  var l1 = new wLogger( { onWrite : _onWrite  } );
  var l2 = new wLogger( { onWrite : _onWrite  } );
  var l3 = new wLogger();
  l2.outputTo( l1, { combining : 'append' } );
  l3.outputTo( l2, { combining : 'append' } );
  l2.outputUnchain( l1 );
  l3.log( 'msg' )
  var expected = [ 'msg' ];
  test.identical( got, expected );

  test.description = 'no args - remove all outputs';
  var l1 = new wLogger();
  test.identical( l1.outputs.length, 1 );
  l1.outputUnchain();
  test.identical( l1.outputs.length, 0 );

  if( Config.debug )
  {
    test.description = 'incorrect type';
    test.shouldThrowError( function()
    {
      logger.outputUnchain( '1' );
    });

    test.description = 'empty outputs list';
    test.shouldThrowError( function()
    {
      var l = new wLogger();
      l.outputTo( logger, { combining : 'rewrite' } );
      l.outputUnchain( logger );
      l.outputUnchain( logger );
    });

  }
}

//

function inputFrom( test )
{
  var onWrite = function ( args ){ got.push( args.output[ 0 ] ) };

  test.description = 'case1: input already exist';
  test.shouldThrowError( function()
  {
    var l1 = new wLogger();
    var l2 = new wLogger({ output : l1 });
    l1.inputFrom( l2 );
  });

  test.description = 'case2: input already exist';
  test.shouldThrowError( function()
  {
    var l = new wLogger();
    l.outputTo( logger, { combining : 'append' } )
    logger.inputFrom( l );
  });

  // !!! needs barringConsole = false
  //
  // test.description = 'case3: console as input';
  // var got = [];
  // var l = new wLogger( { output : null, onWrite : onWrite } );
  // l.inputFrom( console );
  // l._prefix = '*';
  // console.log( 'abc' )
  // var expected = [ '*abc' ];
  // l.inputUnchain( console );
  // test.identical( got, expected );

  test.description = 'case4: logger as input';
  var got = [];
  var l = new wLogger( { onWrite : onWrite } );
  var l2 = new wLogger( );
  l.inputFrom( l2 );
  l._prefix = '--';
  l2.log( 'abc' )
  var expected = [ '--abc' ];
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'no args';
    test.shouldThrowError( function()
    {
      logger.inputFrom();
    });

    test.description = 'incorrect type';
    test.shouldThrowError( function()
    {
      logger.inputFrom( '1' );
    });

    test.description = 'console exists as output';
    test.shouldThrowError( function()
    {
      var logger = new wLogger();
      logger.inputFrom( console );
    });
  }
}

//

function inputUnchain( test )
{
  var onWrite = function ( args ){ got.push( args[0] ) };

  test.description = 'case1: input not exist in the list';
  var l = new wLogger();
  var got = l.inputUnchain( console );
  var expected = false;
  test.identical( got, expected );

  test.description = 'case2: input not exist in the list';
  var l = new wLogger();
  var got = l.inputUnchain( logger );
  var expected = false;
  test.identical( got, expected );

  test.description = 'case3: remove console from input';
  var got = [];
  var l = new wLogger( { output : null,onWrite : onWrite } );
  l.inputFrom( console );
  l.inputUnchain( console );
  console.log( '1' );
  var expected = [];
  test.identical( got, expected );

  test.description = 'case4: remove logger from input';
  var got = [];
  var l1 = new wLogger( { onWrite : onWrite } );
  var l2 = new wLogger();
  l1.inputFrom( l2 );
  l1.inputUnchain( l2 );
  l2.log( '1' );
  var expected = [];
  test.identical( got, expected );

  test.description = 'no args - removes all inputs';
  var l1 = new wLogger();
  var l2 = new wLogger({ output : null });
  l1.inputFrom( l2 );
  test.identical( l1.inputs.length, 1 );
  test.identical( l2.outputs.length, 1 );
  l1.inputUnchain();
  test.identical( l1.inputs.length, 0 );
  test.identical( l2.outputs.length, 0 );

  if( Config.debug )
  {
    test.description = 'incorrect type';
    test.shouldThrowError( function()
    {
      logger.inputUnchain( '1' );
    });
  }
}

//

var Self =
{

  name : 'Chaining test',

  // barringConsole : false,
  /* verbosity : 1, */

  tests :
  {

    levelsTest : levelsTest,
    chaining : chaining,
    chainingParallel : chainingParallel,
    outputTo : outputTo,
    outputUnchain : outputUnchain,
    inputFrom : inputFrom,
    inputUnchain : inputUnchain,

  },

}

//

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
