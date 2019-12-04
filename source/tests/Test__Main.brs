'*****************************************************************
'* Copyright Roku 2011-2017
'* All Rights Reserved
'*****************************************************************


'----------------------------------------------------------------
' Main setup function.
'
' @return A configured TestSuite object.
'----------------------------------------------------------------
Function TestSuite__Main() as Object

    ' Inherite your test suite from BaseTestSuite
    this = BaseTestSuite()

    ' Test suite name for log statistics
    this.Name = "MainTestSuite"

    this.SetUp = MainTestSuite__SetUp
    this.TearDown = MainTestSuite__TearDown

    ' Add tests to suite's tests collection
    this.addTest("CheckDataCount", TestCase__Main_CheckDataCount)
    this.addTest("CheckItemAttributes", TestCase__Main_CheckItemAttributes, TestCase__Main_CheckItemAttributes_Setup, TestCase__Main_CheckItemAttributes_TearDown)
    this.addTest("CheckItemAttributes", TestCase__Main_CheckCWItemAttributes, TestCase__Main_CheckCWItemAttributes_TearDown)
    this.addTest("CheckStreamFormatType", TestCase__Main_CheckStreamFormatType)
    this.addTest("TestComparesAssociativeArrays", TestCase__Main_TestComparesAssociativeArrays)
    this.addTest("TestComparesArrays", TestCase__Main_TestComparesArrays)

    return this
End Function

'----------------------------------------------------------------
' This function called immediately before running tests of current suite.
' This function called to prepare all data for testing.
'----------------------------------------------------------------
Sub MainTestSuite__SetUp()
    ' Target testing object. To avoid the object creation in each test
    ' we create instance of target object here and use it in tests as m.targetTestObject.
    APIURL = "http://vstage-api.mini-me.co/collections?product=https%3A%2F%2Fapi.vhx.tv%2Fproducts%2F37342&type=series"
    m.mainData  = GetApiArray(APIURL)
    m.cwData = GetContinueWatchingArray()
End Sub

'----------------------------------------------------------------
' This function called immediately after running tests of current suite.
' This function called to clean or remove all data for testing.
'----------------------------------------------------------------
Sub MainTestSuite__TearDown()
    ' Remove all the test data
    m.Delete("mainData")
    m.Delete("cwData")
End Sub

'----------------------------------------------------------------
' Check if data has an expected amount of items
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
Function TestCase__Main_CheckDataCount() as String
    return m.assertArrayCount(m.mainData, 9)
End Function

sub TestCase__Main_CheckItemAttributes_Setup()
    ? "--- CheckItemAttributes Test Setup function"
    m.someVariable = "test"
end sub

'----------------------------------------------------------------
' Check if first item has mandatory attributes
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
Function TestCase__Main_CheckItemAttributes() as String
    firstItem = m.mainData[0]
    ? "Access some variable: " m.testinstance.someVariable

    mandatoryAttributes = ["title", "hdposterurl"]

    return m.AssertAAHasKeys(firstItem, mandatoryAttributes)
End Function

sub TestCase__Main_CheckItemAttributes_TearDown()
    ? "--- CheckItemAttributes Test TearDown function"
end sub

'----------------------------------------------------------------
' Check if first cw item has mandatory attributes
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
Function TestCase__Main_CheckCWItemAttributes() as String
    firstItem = m.cwData[0]
    ? "Access some variable: " m.testinstance.someVariable

    mandatoryAttributes = ["title", "hdposterurl", "streamFormat", "description", "id"]

    return m.AssertAAHasKeys(firstItem, mandatoryAttributes)
End Function

sub TestCase__Main_CheckCWItemAttributes_TearDown()
    ? "--- CheckCWItemAttributes Test TearDown function"
end sub

'----------------------------------------------------------------
' Check if stream format of the item is expected
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
Function TestCase__Main_CheckStreamFormatType() as String
    firstItem = m.cwData[0]

    return m.assertEqual(firstItem.streamFormat, "mp4")
End Function

'----------------------------------------------------------------
' Compares two identical associative arrays
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
Function TestCase__Main_TestComparesAssociativeArrays() as String
    array = { key1: "key1", key2: "key2" }

    return m.assertEqual(array, array)
End Function

'----------------------------------------------------------------
' Compares two identical arrays
'
' @return An empty string if test is success or error message if not.
'----------------------------------------------------------------
Function TestCase__Main_TestComparesArrays() as String
    array = ["one", "two"]

    return m.assertEqual(array, array)
End Function
